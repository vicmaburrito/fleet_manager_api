source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"
# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add pagination [https://github.com/ddnexus/pagy]
gem "pagy"

# JSON serializer for Ruby, JRuby and TruffleRuby [https://github.com/okuramasafumi/alba]
gem "alba"

# Validation library with type-safe schemas and rules [https://github.com/dry-rb/dry-validation]
gem "dry-validation"

# A ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard. [https://github.com/jwt/ruby-jwt]
gem "jwt"

# Interactor provides a common interface for performing complex user interactions. [https://github.com/collectiveidea/interactor]
gem "interactor"

# A Ruby gem to load environment variables from `.env`. [https://github.com/bkeepers/dotenv]
gem "dotenv-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # A library for generating fake data such as names, addresses, and phone numbers. [https://github.com/faker-ruby/faker]
  gem "faker"

  # Provides a framework for writing, organizing, and running RSpec tests. [https://github.com/thoughtbot/factory_bot_rails]
  gem "factory_bot_rails"

  # RSpec for Rails 7+ [https://github.com/rspec/rspec-rails]
  gem "rswag-api"
  gem "rswag-ui"
  gem "rswag-specs"

  # Rails Generators for Cucumber with special support for Capybara and DatabaseCleaner. [https://github.com/cucumber/cucumber-rails]
  gem "cucumber-rails", require: false

  # Strategies for cleaning databases using ActiveRecord. Can be used to ensure a clean state for testing. [https://github.com/DatabaseCleaner/database_cleaner-active_record]
  gem "database_cleaner-active_record"

  # RSpec for Rails 7+ [https://github.com/rspec/rspec-rails]
  gem "rspec-rails"

  # Simple one-liner tests for common Rails functionality [https://github.com/thoughtbot/shoulda-matchers]
  gem "shoulda-matchers", "~> 6.0"

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end
