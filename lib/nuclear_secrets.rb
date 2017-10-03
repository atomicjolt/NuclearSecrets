require "nuclear_secrets/engine"

module NuclearSecrets
  class NuclearSecretError < StandardError
    def initialize(secrets: [])
      @secrets = secrets
    end

    def required_type_message(req_type)
      if req_type.nil?
        " of value nil"
      elsif req_type.class == Class
        " of type #{req_type}"
      elsif req_type.class == Proc
        source_pair = req_type.source_location
        " of type Proc (defined in file: #{source_pair.first}, line: #{source_pair.last})"
      else
        " of value #{req_type}"
      end
    end

    def given_type_message(given_type)
      if given_type.nil?
        "\n"
      elsif given_type.class == String
        " was given \"#{given_type}\"\n"
      else
        " was given #{given_type}\n"
      end
    end

    def get_error_list
      @secrets.reduce("") do |message, current|
        message << current.first.to_s
        message << required_type_message(current[1])
        message << given_type_message(current.last)
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

  class InvalidRequiredSecretValue < NuclearSecretError
    def initialize(secrets)
      super(secrets: secrets)
    end

    def message
      "Invalid required secret: \n#{get_error_list}"
    end
  end

  class MismatchedSecretType < NuclearSecretError
    def initialize(secrets)
      super(secrets: secrets)
    end

    def message
      "Invalid secrets given: \n#{get_error_list}"
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

    # secrets: hash of given secrets
    # required_values: hash of required secrets
    # key: key to build tuple for
    # returns [key, required_type, given_type]
    def build_secret_tuple(secrets, required_values, key)
      [key, required_values[key], secrets[key]]
    end

    def build_pairs(keys, secrets)
      keys.map do |k|
        build_secret_tuple(secrets, required_secrets, k)
      end
    end

    def build_assertions(secrets, existing_keys)
      existing_keys.map do |key|
        if required_secrets[key].class == Class
          make_type_check(required_secrets[key])
        elsif required_secrets[key].respond_to? :call
          required_secrets[key]
        else
          raise NuclearSecrets::InvalidRequiredSecretValue.new(
            [
              build_secret_tuple(secrets, required_secrets, key),
            ],
          )
        end
      end
    end

    def check_assertions(secrets, assertions)
      secrets.to_a.zip(assertions).select do |pair|
        result = pair.last.call(pair.first[1])
        if !result
          pair.first[0]
        else
          false
        end
      end.map do |pair|
        flat_pair = pair.flatten
        build_secret_tuple(secrets, required_secrets, flat_pair.first)
      end
    end

    def check_secrets(secrets)
      raise NuclearSecrets::RequiredSecretsListMissing if required_secrets.nil?
      req_keys = required_secrets.keys
      existing_keys = secrets.keys

      missing_keys = req_keys - existing_keys
      extra_keys = existing_keys - req_keys

      missing_pairs = build_pairs(missing_keys, secrets)
      extra_pairs = build_pairs(extra_keys, secrets)
      raise SecretsMissingError.new(missing_pairs) unless missing_keys.empty?
      raise ExtraSecretsError.new(extra_pairs) unless extra_keys.empty?

      assertions = build_assertions(secrets, existing_keys)
      error_pairs = check_assertions(secrets, assertions)
      raise MismatchedSecretType.new(error_pairs) if !error_pairs.empty?
    end
  end
end
