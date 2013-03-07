source "http://rubygems.org"

# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

#==============================================================================
# Gems used in both development and testing environments.
#==============================================================================
group :development, :test do

  # Use YARD documentation format
  gem "yard", "~> 0.7"
  gem "rdoc", "~> 3.12"
  gem "bundler", "~> 1.0"

  # Use Jeweler to build our gem
  gem "jeweler", "~> 1.8.4"

  # RSpec for our testing framework
  gem "rspec", "~> 2.8.0"
end

#==============================================================================
# Gems just needed for testing.
#==============================================================================
group :test do

  # Faker generates names, email addresses, and other placeholders for factories
  gem 'ffaker'

  # For testing ActiveRecord extensions
  gem 'acts_as_fu'

  # Test time-dependent functionality
  gem 'timecop'

  if RUBY_VERSION > '1.9'
    gem "simplecov", :require => false
  else
    gem "rcov", ">= 0"
  end
end