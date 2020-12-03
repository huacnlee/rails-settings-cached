# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require "rails-settings/version"

Gem::Specification.new do |s|
  s.name          = "rails-settings-cached"
  s.version       = RailsSettings.version
  s.authors       = ["Jason Lee"]
  s.email         = "huacnlee@gmail.com"
  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.homepage      = "https://github.com/huacnlee/rails-settings-cached"
  s.require_paths = ["lib"]
  s.license = "MIT"

  s.required_ruby_version = ">= 2.5"
  s.summary = "Settings plugin for Rails that makes managing a table of global keys."
  s.description = """
  This is improved from rails-settings, added caching.
  Settings plugin for Rails that makes managing a table of global key,
  value pairs easy. Think of it like a global Hash stored in you database,
  that uses simple ActiveRecord like methods for manipulation.

  Keep track of any global setting that you dont want to hard code into your rails app.
  You can store any kind of object.  Strings, numbers, arrays, or any object.
  """

  s.add_dependency "rails", ">= 4.2.0"

  s.add_development_dependency "codecov"
  s.add_development_dependency "minitest"
  s.add_development_dependency "pg"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "sqlite3"
end
