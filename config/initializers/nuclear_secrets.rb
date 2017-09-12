module NuclearSecrets
  class Application < Rails::Application
    config.before_initialize do
      NuclearSecrets::check_secrets(Rails.application.secrets)
    end
  end
end
