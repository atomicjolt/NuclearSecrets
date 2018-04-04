require "nuclear_secrets/engine"
require "nuclear_secrets/errors"
require "logger"

module NuclearSecrets
  class << self
    attr_accessor(:required_secrets)
    attr_accessor(:settings)

    def configure
      yield self if block_given?
    end

    def init_settings
      @settings = {} unless @settings.is_a? Hash
      @settings = default_settings.merge(@settings)
    end

    def default_settings
      {
        raise_on_extra_secrets: false,
      }
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
          ) if @settings[:raise_on_extra_secrets] == true
        end
      end.compact
    end

    def check_assertions(secrets, assertions)
      secrets.to_a.zip(assertions).select do |pair|
        result = if pair.last.present?
                   pair.last.call(pair.first[1])
                 end
        if !result && @settings[:raise_on_extra_secrets] == true
          pair.first[0]
        else
          false
        end
      end.map do |pair|
        flat_pair = pair.flatten
        build_secret_tuple(secrets, required_secrets, flat_pair.first)
      end
    end

    def handle_extra_keys(extra_keys, extra_pairs)
      raise ExtraSecretsError.new(extra_pairs) unless extra_keys.empty?
    rescue ExtraSecretsError => e
      logger = Logger.new(STDOUT)
      logger.warn e.message
      raise e if @settings[:raise_on_extra_secrets] == true
    end

    def check_secrets(secrets)
      init_settings
      raise NuclearSecrets::RequiredSecretsListMissing if required_secrets.nil?
      req_keys = required_secrets.keys
      existing_keys = secrets.keys

      missing_keys = req_keys - existing_keys
      extra_keys = existing_keys - req_keys

      missing_pairs = build_pairs(missing_keys, secrets)
      extra_pairs = build_pairs(extra_keys, secrets)
      raise SecretsMissingError.new(missing_pairs) unless missing_keys.empty?
      handle_extra_keys(extra_keys, extra_pairs)

      assertions = build_assertions(secrets, existing_keys)
      error_pairs = check_assertions(secrets, assertions)
      raise MismatchedSecretType.new(error_pairs) if !error_pairs.empty?
    end
  end
end
