module NuclearSecrets
  class Application < Rails::Application
    config.after_initialize do
      NuclearSecrets::check_secrets(Rails.application.secrets)
    end
  end
end
