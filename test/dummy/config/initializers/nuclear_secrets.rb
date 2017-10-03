NuclearSecrets.configure do |config|
  config.required_secrets = {
    #secret_key_base: String,
    secret_token: NilClass,
    secret_key_base: Proc.new { false } 
  }
end
