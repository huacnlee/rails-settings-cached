# coding: utf-8
Gem::Specification.new do |s|
  s.name = %q{rails-settings-cached}
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Squeegy", "Georg Ledermann", "100hz", "Jason Lee"]
  s.email = %q{huacnlee@gmail.com}
	s.files = Dir.glob("lib/**/*") + %w(README.md)
  s.homepage = %q{https://github.com/huacnlee/rails-settings-cached}
  s.require_paths = ["lib"]
  s.summary = %q{This is imporved from rails-settings, added caching. Settings is a plugin that makes managing a table of global key, value pairs easy. Think of it like a global Hash stored in you database, that uses simple ActiveRecord like methods for manipulation.  Keep track of any global setting that you dont want to hard code into your rails app.  You can store any kind of object.  Strings, numbers, arrays, or any object. Ported to Rails 3!}

  s.add_dependency("rails", [">= 4.0.0"])
end

