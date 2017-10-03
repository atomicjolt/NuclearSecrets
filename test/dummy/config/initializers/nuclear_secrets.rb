NuclearSecrets.configure do |config|
  config.required_secrets = {
    secret_key_base: String,
    secret_token: NilClass,
  }
end
