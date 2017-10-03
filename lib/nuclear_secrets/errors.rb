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
end
