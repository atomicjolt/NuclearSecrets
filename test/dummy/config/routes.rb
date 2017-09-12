Rails.application.routes.draw do
  mount NuclearSecrets::Engine => "/nuclear_secrets"
end
