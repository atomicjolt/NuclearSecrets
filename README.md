# Nuclear Secrets
Quell rails secret espionage by verifying what secrets exist and their types in your rails application

## Usage
Record all application secrets and their appropriate types in Nuclear Secrets initializer.
If your application loads secrets that are not recorded, or your app does not load a
required secret, your rails app will crash and inform you of what missing or extra
secrets exist.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'nuclear_secrets'
```

And then execute:
```bash
$ bundle
```

Add initializer to your rails application at `config/initializers/nuclear_secrets.rb`
```ruby
NuclearSecrets.configure do |config|
  config.required_secrets = {
    my_string_secret: String,
    my_numeric_secret: Fixnum,
  }
end
```
Include all secrets that your application utilizes, and their types, in `required_secrets` hash

## Advanced Usage
In addition to being able to supply NuclearSecrets with the type of a secret,
you can also pass a Proc or a Lambda. If the proc or lamba returns true when
passed the value of the secret, then the secret will be allowed.

```
NuclearSecrets.configure do |config|
  config.required_secrets = {
    my_string_secret: String,
    my_numeric_secret: Fixnum,
    my_secret: Proc.new { |secret| secret.is_worthy? }
  }
end
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
