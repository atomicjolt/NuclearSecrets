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
      "You must include a required_secrets key in your config/secrets.yml file"
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

    def check_secrets(secrets)
      raise NuclearSecrets::RequiredSecretsListMissing if required_secrets.nil?
      req_secret_pairs = required_secrets.map { |pair| [pair.first.to_sym, pair.last.to_s] }
      types = secrets.map { |pair| [pair.first, pair.last.class.to_s] }

      missing_secrets = req_secret_pairs - types
      extra_secrets = types - req_secret_pairs

      # TODO type error message
      # TODO add config type checking
      # TODO accept types in config
      raise SecretsMissingError.new(missing_secrets) unless missing_secrets.empty?
      raise ExtraSecretsError.new(extra_secrets) unless extra_secrets.empty?
    end
  end
end
