$:.push File.expand_path("../lib", __FILE__)
require "rails-settings/version"

Gem::Specification.new do |s|
  s.name          = 'rails-settings-cached'
  s.version       = RailsSettings.version
  s.authors       = ['Jason Lee', 'Squeegy', 'Georg Ledermann', '100hz']
  s.email         = 'huacnlee@gmail.com'
  s.files         = Dir.glob('lib/**/*') + %w(README.md)
  s.homepage      = 'https://github.com/huacnlee/rails-settings-cached'
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.1'
  s.summary = "Settings plugin for Rails that makes managing a table of global keys."
  s.description = """
  This is improved from rails-settings, added caching.
  Settings plugin for Rails that makes managing a table of global key,
  value pairs easy. Think of it like a global Hash stored in you database,
  that uses simple ActiveRecord like methods for manipulation.

  Keep track of any global setting that you dont want to hard code into your rails app.
  You can store any kind of object.  Strings, numbers, arrays, or any object.
  """

  s.add_dependency 'rails', '>= 4.2.0'
  s.add_dependency 'settingslogic', '>= 2.0.0'
end
