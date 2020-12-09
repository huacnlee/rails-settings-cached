# Rails Settings Cached

The best solution for store global settings in Rails applications.

This gem will managing a table of а global key, value pairs easy. Think of it like a global Hash stored in your database, that uses simple ActiveRecord like methods for manipulation. Keep track of any global setting that you don't want to hard code into your rails app.

You can store any kind of object. Strings, numbers, arrays, booleans, or any object.

[![Gem Version](https://badge.fury.io/rb/rails-settings-cached.svg)](https://rubygems.org/gems/rails-settings-cached) [![CI Status](https://travis-ci.org/huacnlee/rails-settings-cached.svg)](http://travis-ci.org/huacnlee/rails-settings-cached) [![codecov.io](https://codecov.io/github/huacnlee/rails-settings-cached/coverage.svg?branch=master)](https://codecov.io/github/huacnlee/rails-settings-cached?branch=master)

## Installation

Edit your Gemfile:

```bash
$ bundle add rails-settings-cached
```

Generate your settings:

```bash
$ rails g settings:install

# Or use a custom name:
$ rails g settings:install AppConfig
```

You will get `app/models/setting.rb`

```rb
class Setting < RailsSettings::Base
  # cache_prefix { "v1" }
  field :app_name, default: "Rails Settings", validates: { presence: true, length: { in: 2..20 } }
  field :host, default: "http://example.com", readonly: true
  field :default_locale, default: "zh-CN", validates: { presence: true, inclusion: { in: %w[zh-CN en jp] } }
  field :readonly_item, type: :integer, default: 100, readonly: true
  field :user_limits, type: :integer, default: 20
  field :exchange_rate, type: :float, default: 0.123
  field :admin_emails, type: :array, default: %w[admin@rubyonrails.org]
  field :captcha_enable, type: :boolean, default: true

  # Override array separator, default: /[\n,]/ split with \n or comma.
  field :tips, type: :array, separator: /[\n]+/

  field :notification_options, type: :hash, default: {
    send_all: true,
    logging: true,
    sender_email: "foo@bar.com"
  }

  # lambda default value
  field :welcome_message, type: :string, default: -> { "welcome to #{self.app_name}" }, validates: { length: { maximum: 255 } }
end
```

You must use the `field` method to statement the setting keys, otherwise you can't use it.

Now just put that migration in the database with:

```bash
$ rails db:migrate
```

## Usage

The syntax is easy. First, let's create some settings to keep track of:

```ruby
irb > Setting.host
"http://example.com"
irb > Setting.app_name
"Rails Settings"
irb > Setting.app_name = "Rails Settings Cached"
irb > Setting.app_name
"Rails Settings Cached"

irb > Setting.user_limits
20
irb > Setting.user_limits = "30"
irb > Setting.user_limits
30
irb > Setting.user_limits = 45
irb > Setting.user_limits
45

irb > Setting.captcha_enable
1
irb > Setting.captcha_enable?
true
irb > Setting.captcha_enable = "0"
irb > Setting.captcha_enable
false
irb > Setting.captcha_enable = "1"
irb > Setting.captcha_enable
true
irb > Setting.captcha_enable = "false"
irb > Setting.captcha_enable
false
irb > Setting.captcha_enable = "true"
irb > Setting.captcha_enable
true
irb > Setting.captcha_enable?
true

irb > Setting.admin_emails
["admin@rubyonrails.org"]
irb > Setting.admin_emails = %w[foo@bar.com bar@dar.com]
irb > Setting.admin_emails
["foo@bar.com", "bar@dar.com"]
irb > Setting.admin_emails = "huacnlee@gmail.com,admin@admin.com\nadmin@rubyonrails.org"
irb > Setting.admin_emails
["huacnlee@gmail.com", "admin@admin.com", "admin@rubyonrails.org"]

irb > Setting.notification_options
{
  send_all: true,
  logging: true,
  sender_email: "foo@bar.com"
}
irb > Setting.notification_options = {
  sender_email: "notice@rubyonrails.org"
}
irb > Setting.notification_options
{
  sender_email: "notice@rubyonrails.org"
}
```

### Get defined fields

> version 2.3+

```rb
# Get all keys
Setting.keys
=> ["app_name", "host", "default_locale", "readonly_item"]

# Get editable keys
Settng.editable_keys
=> ["app_name", "default_locale"]

# Get readonly keys
Setting.readonly_keys
=> ["host", "readonly_item"]

# Get options of field
Setting.get_field("host")
=> { key: "host", type: :string, default: "http://example.com", readonly: true }
Setting.get_field("app_name")
=> { key: "app_name", type: :string, default: "Rails Settings", readonly: false }
```

## Validations

You can use `validates` options to special the [Rails Validation](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates) for fields.

```rb
class Setting < RailsSettings::Base
  # cache_prefix { "v1" }
  field :app_name, default: "Rails Settings", validates: { presence: true, length: { in: 2..20 } }
  field :default_locale, default: "zh-CN", validates: { presence: true, inclusion: { in: %w[zh-CN en jp], message: "is not included in [zh-CN, en, jp]" } }
end
```

Now validate will work on record save:

```rb
irb> Setting.app_name = ""
ActiveRecord::RecordInvalid: (Validation failed: App name can't be blank)
irb> Setting.app_name = "Rails Settings"
"Rails Settings"
irb> Setting.default_locale = "zh-TW"
ActiveRecord::RecordInvalid: (Validation failed: Default locale is not included in [zh-CN, en, jp])
irb> Setting.default_locale = "en"
"en"
```

Validate by `save` / `valid?` method:

```rb

setting = Setting.find_or_initialize_by(var: :app_name)
setting.value = ""
setting.valid?
# => false
setting.errors.full_messages
# => ["App name can't be blank", "App name too short (minimum is 2 characters)"]

setting = Setting.find_or_initialize_by(var: :default_locale)
setting.value = "zh-TW"
setting.save
# => false
setting.errors.full_messages
# => ["Default locale is not included in [zh-CN, en, jp]"]
setting.value = "en"
setting.valid?
# => true
```

## Use Setting in Rails initializing:

In `version 2.3+` you can use Setting before Rails is initialized.

For example `config/initializers/devise.rb`

```rb
Devise.setup do |config|
  if Setting.omniauth_google_client_id.present?
    config.omniauth :google_oauth2, Setting.omniauth_google_client_id, Setting.omniauth_google_client_secret
  end
end
```

```rb
class Setting < RailsSettings::Base
  field :omniauth_google_client_id, default: ENV["OMNIAUTH_GOOGLE_CLIENT_ID"]
  field :omniauth_google_client_secret, default: ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"]
end
```

## Readonly field

You may also want use Setting before Rails initialize:

```
config/environments/*.rb
```

If you want do that do that, the setting field must has `readonly: true`.

For example:

```rb
class Setting < RailsSettings::Base
  field :mailer_provider, default: (ENV["mailer_provider"] || "smtp"), readonly: true
  field :mailer_options, type: :hash, readonly: true, default: {
    address: ENV["mailer_options.address"],
    port: ENV["mailer_options.port"],
    domain: ENV["mailer_options.domain"],
    user_name: ENV["mailer_options.user_name"],
    password: ENV["mailer_options.password"],
    authentication: ENV["mailer_options.authentication"] || "login",
    enable_starttls_auto: ENV["mailer_options.enable_starttls_auto"]
  }
end
```

config/environments/production.rb

```rb
# You must require_relative directly in Rails 6.1+ in config/environments/production.rb
require_relative "../../app/models/setting"

Rails.application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = Setting.mailer_options.deep_symbolize_keys
end
```

## Caching flow:

```
Setting.host -> Check Cache -> Exist - Get value of key for cache -> Return
                   |
                Fetch all key and values from DB -> Write Cache -> Get value of key for cache -> return
                   |
                Return default value or nil
```

In each Setting keys call, we will load the cache/db and save in [ActiveSupport::CurrentAttributes](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html) to avoid hit cache/db.

Each key update will expire the cache, so do not add some frequent update key.

## Change cache key

Some times you may need to force update cache, now you can use `cache_prefix`

```ruby
class Setting < RailsSettings::Base
  cache_prefix { "you-prefix" }
  ...
end
```

In testing, you need add `Setting.clear_cache` for each Test case:

```rb
class ActiveSupport::TestCase
  teardown do
    Setting.clear_cache
  end
end
```

---

## How to manage Settings in the admin interface?

If you want to create an admin interface to editing the Settings, you can try methods in following:

config/routes.rb

```rb
namespace :admin do
  resource :settings
end
```

app/controllers/admin/settings_controller.rb

```rb
module Admin
  class SettingsController < ApplicationController
    def create
      @errors = ActiveModel::Errors.new
      setting_params.keys.each do |key|
        next if setting_params[key].nil?

        setting = Setting.new(var: key)
        setting.value = setting_params[key].strip
        unless setting.valid?
          @errors.merge!(setting.errors)
        end
      end

      if @errors.any?
        render :new
      end

      setting_params.keys.each do |key|
        Setting.send("#{key}=", setting_params[key].strip) unless setting_params[key].nil?
      end

      redirect_to admin_settings_path, notice: "Setting was successfully updated."
    end

    private
      def setting_params
        params.require(:setting).permit(:host, :user_limits, :admin_emails,
          :captcha_enable, :notification_options)
      end
  end
end
```

app/views/admin/settings/show.html.erb

```erb
<%= form_for(Setting.new, url: admin_settings_path) do |f| %>
  <% if @errors.any? %>
    <div class="alert alert-block alert-danger">
      <ul>
        <% @errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-group">
    <label class="control-label">Host</label>
    <%= f.text_field :host, value: Setting.host, class: "form-control", placeholder: "http://localhost"  %>
  </div>

  <div class="form-group form-checkbox">
    <label>
      <%= f.check_box :captcha_enable, checked: Setting.captcha_enable? %>
      Enable/Disable Captcha
    </label>
  </div>

  <div class="form-group">
    <label class="control-label">Admin Emails</label>
    <%= f.text_area :admin_emails, value: Setting.admin_emails.join("\n"), class: "form-control" %>
  </div>

  <div class="form-group">
    <label class="control-label">Notification options</label>
    <%= f.text_area :notification_options, value: YAML.dump(Setting.notification_options), class: "form-control", style: "height: 180px;"  %>
    <div class="form-text">
      Use YAML format to config the SMTP_html
    </div>
  </div>

  <div>
    <%= f.submit 'Update Settings' %>
  </div>
<% end %>
```

## Scoped Settings

> 🚨 BREAK CHANGES WARNING:
> rails-settings-cached 2.x has redesigned the API, the new version will compatible with the stored setting values by an older version.
> When you want to upgrade 2.x, you must read the README again, and follow guides to change your Setting model.
> 0.x stable branch: https://github.com/huacnlee/rails-settings-cached/tree/0.x

- [Backward compatible to support 0.x scoped settings](docs/backward-compatible-to-scoped-settings.md)

For new project / new user of rails-settings-cached. The [ActiveRecord::AttributeMethods::Serialization](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html#method-i-serialize) is best choice.

> This is reason of why rails-settings-cached 2.x removed **Scoped Settings** feature.

For example:

We wants a preferences setting for user.

```rb
class User < ActiveRecord::Base
  serialize :preferences
end

@user = User.new
@user.preferences[:receive_emails] = true
@user.preferences[:public_email] = true
@user.save
```

## Use cases:

- [ruby-china/homeland](https://github.com/ruby-china/homeland) - master
- [forem/forem](https://github.com/forem/forem) - 2.x
- [siwapp/siwapp](https://github.com/siwapp/siwapp) - 2.x
- [aidewoode/black_candy](https://github.com/aidewoode/black_candy) - 2.x
- [huacnlee/bluedoc](https://github.com/huacnlee/bluedoc) - 2.x
- [getzealot/zealot](https://github.com/getzealot/zealot) - 2.x
- [kaishuu0123/rebacklogs](https://github.com/kaishuu0123/rebacklogs) - 2.x
- [tootsuite/mastodon](https://github.com/tootsuite/mastodon) - 0.6.x
- [helpyio/helpy](https://github.com/helpyio/helpy) - 0.5.x
- [daqing/rabel](https://github.com/daqing/rabel) - 0.4.x

And more than [1K repositories](https://github.com/huacnlee/rails-settings-cached/network/dependents) used.
