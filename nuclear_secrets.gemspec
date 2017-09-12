$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "nuclear_secrets/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "nuclear_secrets"
  s.version     = NuclearSecrets::VERSION
  s.authors     = ["Nick Benoit"]
  s.email       = ["nick.benoit14@gmail.com"]
  s.homepage    = "https://example.com/asdf"
  s.summary     = "asdf"
  s.description = "asdf"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0"

  s.add_development_dependency "sqlite3"
end
