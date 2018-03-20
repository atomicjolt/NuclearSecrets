$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "nuclear_secrets/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "nuclear_secrets"
  s.version     = NuclearSecrets::VERSION
  s.authors     = ["Atomic Jolt", "Nick Benoit"]
  s.email       = ["nick.benoit14@gmail.com"]
  s.summary     = "Quell rails secret espionage by verifying what secrets exist and their types in your rails application"
  s.description = "Rails secrets checker"
  s.homepage    = "https://github.com/atomicjolt/NuclearSecrets"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.0.0"

  s.add_development_dependency "sqlite3"
end
