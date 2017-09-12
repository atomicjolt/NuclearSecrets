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

  class Application < Rails::Application
    config.before_initialize do
      secrets = Rails.application.secrets
      raise NuclearSecrets::RequiredValuesMissing unless secrets.required_secrets.present?
      required_secrets = secrets.required_secrets.map { |pair| [pair.first.to_sym, pair.last] }
      types = Rails.application.secrets.map { |pair| [pair.first, pair.last.class.to_s] }

      missing_secrets = required_secrets - types
      extra_secrets = types - required_secrets

      raise SecretsMissingError.new(missing_secrets) unless missing_secrets.empty?
      raise ExtraSecretsError.new(extra_secrets) unless extra_secrets.empty?
    end
  end
end
