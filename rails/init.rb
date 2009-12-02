require File.join(File.dirname(__FILE__), "/../lib/publishable")
ActiveRecord::Base.send :include, Publishable