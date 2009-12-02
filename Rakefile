require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec)
task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "publishable"
    gemspec.summary = "Adds publishing functionality to your active record model"
    gemspec.description = "Provides methods to publish and unpublish your active record models based on a datetime. Also adds named scopes to nicely filter your records. Does not touch any controller or views."
    gemspec.email = "m.linkhorst@googlemail.com"
    gemspec.homepage = "http://github.com/linki/publishable"
    gemspec.authors = ["Martin Linkhorst"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end