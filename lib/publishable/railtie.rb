require 'rails/railtie'

module Publishable
  class Railtie < Rails::Railtie
    initializer 'publishable.initialize' do |app|
      ActiveRecord::Base.extend Publishable::ClassMethods
    end
  end
end