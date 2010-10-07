require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new() do |gem|
    gem.name = "rails-settings"
    gem.summary = "Settings is a plugin that makes managing a table of global key, value pairs easy. Think of it like a global Hash stored in you database, that uses simple ActiveRecord like methods for manipulation.  Keep track of any global setting that you dont want to hard code into your rails app.  You can store any kind of object.  Strings, numbers, arrays, or any object. Ported to Rails 3!"
    gem.email = "rails-settings@theblackestbox.net"
    gem.homepage = "http://theblackestbox.net"
    gem.authors = ["Squeegy","Georg Ledermann","100hz"]
    gem.add_dependency "rails", ">= 3.0.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end


task :default => :release