# Settings Gem

This is improved from [rails-settings](https://github.com/ledermann/rails-settings),
added caching for all settings. Settings is a plugin that makes managing a table of
global key, value pairs easy. Think of it like a global Hash stored in your database,
that uses simple ActiveRecord like methods for manipulation. Keep track of any global
setting that you dont want to hard code into your rails app. You can store any kind
of object. Strings, numbers, arrays, or any object.

## Status

[![Gem Version](https://badge.fury.io/rb/rails-settings-cached.svg)](https://rubygems.org/gems/rails-settings-cached) [![CI Status](https://api.travis-ci.org/huacnlee/rails-settings-cached.svg)](http://travis-ci.org/huacnlee/rails-settings-cached) [![Code Climate](https://codeclimate.com/github/huacnlee/rails-settings-cached/badges/gpa.svg)](https://codeclimate.com/github/huacnlee/rails-settings-cached) [![codecov.io](https://codecov.io/github/huacnlee/rails-settings-cached/coverage.svg?branch=master)](https://codecov.io/github/huacnlee/rails-settings-cached?branch=master)

## Setup

Edit your Gemfile:

```ruby
gem 'rails-settings-cached', "~> 0.5.6"
```

Older Rails versions:

```rb
# 4.1.x
gem "rails-settings-cached", "~> 0.4.0"
# 4.0.x
gem "rails-settings-cached", "0.3.1"
# 3.x
gem "rails-settings-cached", "0.2.4"
```

Generate your settings:

```bash
$ rails g settings:install
```

If you want custom model name:

```bash
$ rails g settings:install MySetting
```

Now just put that migration in the database with:

```bash
rake db:migrate
```

## Usage

The syntax is easy.  First, lets create some settings to keep track of:

```ruby
Setting.admin_password = 'supersecret'
Setting.date_format    = '%m %d, %Y'
Setting.cocktails      = ['Martini', 'Screwdriver', 'White Russian']
Setting.foo            = 123
Setting.credentials    = { :username => 'tom', :password => 'secret' }
```

Now lets read them back:

```ruby
Setting.foo            # returns 123
```

Changing an existing setting is the same as creating a new setting:

```ruby
Setting.foo = 'super duper bar'
```

For changing an existing setting which is a Hash, you can merge new values with existing ones:

```ruby
Setting.merge!(:credentials, :password => 'topsecret')
Setting.credentials    # returns { :username => 'tom', :password => 'topsecret' }
```

Decide you dont want to track a particular setting anymore?

```ruby
Setting.destroy :foo
Setting.foo            # returns nil
```

Want a list of all the settings?
```ruby
# Rails 4.1.x
Setting.get_all
# Rails 3.x and 4.0.x
Setting.all
# returns {'admin_password' => 'super_secret', 'date_format' => '%m %d, %Y'}
```

You need name spaces and want a list of settings for a give name space? Just choose your prefered named space delimiter and use `Setting.get_all` (`Settings.all` for # Rails 3.x and 4.0.x) like this:

```ruby
Setting['preferences.color'] = :blue
Setting['preferences.size'] = :large
Setting['license.key'] = 'ABC-DEF'
# Rails 4.1.x
Setting.get_all('preferences.')
# Rails 3.x and 4.0.x
Setting.all('preferences.')
# returns { 'preferences.color' => :blue, 'preferences.size' => :large }
```

Set defaults for certain settings of your app.  This will cause the defined settings to return with the
Specified value even if they are **not in the database**.  Make a new file in `config/initializers/default_settings.rb`
with the following:

```ruby
Setting.defaults[:some_setting] = 'footastic'
Setting.where(:var => "some_setting").count
=> 0
Setting.some_setting
=> "footastic"
```

Init default value in database, this has indifferent with `Setting.defaults[:some_setting]`, this will **save the value into database**:

```ruby
Setting.save_default(:some_key, "123")
Setting.where(:var => "some_key").count
=> 1
Setting.some_key
=> "123"
```

Settings may be bound to any existing ActiveRecord object. Define this association like this:
Notice! is not do caching in this version.

```ruby
class User < ActiveRecord::Base
  include RailsSettings::Extend
end
```

Then you can set/get a setting for a given user instance just by doing this:

```ruby
user = User.find(123)
user.settings.color = :red
user.settings.color # returns :red
# Rails 4.1.x
user.settings.get_all
# Rails 3.x and 4.0.x
user.settings.all
# { "color" => :red }
```

If you want to find users having or not having some settings, there are named scopes for this:

```ruby
User.with_settings
# => returns a scope of users having any setting

User.with_settings_for('color')
# => returns a scope of users having a 'color' setting

User.with_setting_value('color', 'red')
# => returns a scope of users having a 'color' setting with value 'red'

User.without_settings
# returns a scope of users having no setting at all (means user.settings.get_all == {})

User.without_settings('color')
# returns a scope of users having no 'color' setting (means user.settings.color == nil)
```

Settings maybe dynamically scoped. For example, if you're using [apartment gem](https://github.com/influitive/apartment) for multitenancy, you may not want tenants to share settings:

```ruby
class Settings < RailsSettings::CachedSettings
  cache_prefix { Apartment::Tenant.current }
  ...
end
```

-----

## How to create a list, form to manage Settings?

If you want create an admin interface to editing the Settings, you can try methods in follow:

```ruby
class SettingsController < ApplicationController
  def index
    # to get all items for render list
    @settings = Setting.unscoped
  end

  def edit
    @setting = Setting.unscoped.find(params[:id])
  end
end
```


Also you may use [rails-settings-ui](https://github.com/accessd/rails-settings-ui) gem
for building ready to using interface with validations.

