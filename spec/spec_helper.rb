$: << File.join(File.dirname(__FILE__), "/../lib" )
require 'rubygems'
require 'spec'

require 'active_record'
require 'active_support'

require 'publishable'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end