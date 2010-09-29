$:.unshift File.expand_path('../../lib', __FILE__)
require 'publishable'
require 'spec'
require 'spec/autorun'

require 'sqlite3'
require 'active_record'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
