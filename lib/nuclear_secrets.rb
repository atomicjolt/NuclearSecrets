require "nuclear_secrets/engine"

module NuclearSecrets
  class NuclearSecretError < StandardError
    def initialize(secrets: [])
      @secrets = secrets
    end

    def get_error_list
      @secrets.reduce("") do |message, current|
        message << "#{current.first} of type #{current.last} \n"
      end
    end
  end

  class RequiredSecretsListMissing < NuclearSecretError
    def message
      "You must include a NuclearSecrets initializer in your app"
    end
  end

  class SecretsMissingError < NuclearSecretError
    def initialize(secrets)
      super(secrets: secrets)
    end

    def message
      "Missing secrets: \n#{get_error_list}"
    end
  end

  class ExtraSecretsError < NuclearSecretError
    def initialize(secrets)
      super(secrets: secrets)
    end

    def message
      "Secrets not included in required_secrets list: \n#{get_error_list}"
    end
  end

  class << self
    attr_accessor(:required_secrets)

    def configure
      yield self if block_given?
    end

    def make_type_check(type)
      Proc.new { |item| item.class == type }
    end

    def build_assertions(existing_keys)
      existing_keys.map do |key|
        if required_secrets[key].class == Class
          make_type_check(required_secrets[key])
        elsif required_secrets[key].respond_to? :call
          required_secrets[key]
        else
          # TODO
          # Throw invalid value error
          raise "Bad assert"
        end
      end
    end 

    def check_assertions(secrets, assertions)
      secrets.to_a.zip(assertions).map do |pair|
        result = pair.last.call(pair.first[1])
        if result
          nil
        else
          # TODO 
          StandardError.new("BAAAD")
        end
      end
    end

    def check_secrets(secrets)
      raise NuclearSecrets::RequiredSecretsListMissing if required_secrets.nil?
      req_keys = required_secrets.keys
      existing_keys = secrets.keys

      missing_keys = req_keys - existing_keys
      extra_keys = existing_keys - req_keys

      #TODO refactor errors
      #TODO add wrong type error
      raise SecretsMissingError.new(missing_keys) unless missing_keys.empty?
      raise ExtraSecretsError.new(extra_keys) unless extra_keys.empty?    
      assertions = build_assertions(existing_keys)
      errors = check_assertions(secrets, assertions)
      errors.compact.each do |err|
        raise err
      end
    end
  end
end
