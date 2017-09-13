NuclearSecrets.configure do |config|
  config.required_secrets = {
    secret_key_base: String.to_s,
    secret_token: NilClass.to_s,
  }
end
