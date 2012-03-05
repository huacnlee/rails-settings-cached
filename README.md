# Settings Gem

This is improved from rails-settings, added caching for all settings.
Settings is a plugin that makes managing a table of global key, value pairs easy.
Think of it like a global Hash stored in you database, that uses simple ActiveRecord
like methods for manipulation.  Keep track of any global setting that you dont want
to hard code into your rails app.  You can store any kind of object.  Strings, numbers,
arrays, or any object. Ported to Rails 3!

## Status

[![CI Status](https://secure.travis-ci.org/huacnlee/rails-settings-cached.png)](http://travis-ci.org/huacnlee/rails-settings-cached)

## Setup

Edit your Gemfile:

    gem "rails-settings-cached"

Generate your settings:

    rails g settings <settings_name>

Now just put that migration in the database with:
    
    rake db:migrate

## Usage

The syntax is easy.  First, lets create some settings to keep track of:

    Setting.admin_password = 'supersecret'
    Setting.date_format    = '%m %d, %Y'
    Setting.cocktails      = ['Martini', 'Screwdriver', 'White Russian']
    Setting.foo            = 123
    Setting.credentials    = { :username => 'tom', :password => 'secret' }

Now lets read them back:

    Setting.foo            # returns 123

Changing an existing setting is the same as creating a new setting:

    Setting.foo = 'super duper bar'

For changing an existing setting which is a Hash, you can merge new values with existing ones:

    Setting.merge!(:credentials, :password => 'topsecret')
    Setting.credentials    # returns { :username => 'tom', :password => 'topsecret' }

Decide you dont want to track a particular setting anymore?

    Setting.destroy :foo
    Setting.foo            # returns nil

Want a list of all the settings?

    Setting.all            # returns {'admin_password' => 'super_secret', 'date_format' => '%m %d, %Y'}

You need name spaces and want a list of settings for a give name space? Just choose your prefered named space delimiter and use Setting.all like this:

    Setting['preferences.color'] = :blue
    Setting['preferences.size'] = :large
    Setting['license.key'] = 'ABC-DEF'
    Setting.all('preferences.')   # returns { 'preferences.color' => :blue, 'preferences.size' => :large }

Set defaults for certain settings of your app.  This will cause the defined settings to return with the
Specified value even if they are not in the database.  Make a new file in `config/initializers/default_settings.rb`
with the following:

    Setting.defaults[:some_setting] = 'footastic'
  
Now even if the database is completely empty, you app will have some intelligent defaults:

    Setting.some_setting   # returns 'footastic'

Settings may be bound to any existing ActiveRecord object. Define this association like this:
Notice! is not do caching in this version.
  
    class User < ActiveRecord::Base
      include RailsSettings::Extend 
    end

Then you can set/get a setting for a given user instance just by doing this:

    user = User.find(123)
    user.settings.color = :red
    user.settings.color # returns :red
    user.settings.all # { "color" => :red }

I you want to find users having or not having some settings, there are named scopes for this:

    User.with_settings # => returns a scope of users having any setting
    User.with_settings_for('color') # => returns a scope of users having a 'color' setting
  
    User.without_settings # returns a scope of users having no setting at all (means user.settings.all == {})
    User.without_settings('color') # returns a scope of users having no 'color' setting (means user.settings.color == nil)

That's all there is to it! Enjoy!
