# Rails Settings Cached

The best solution for store global settings in Rails applications.

This gem will make managing a table of а global key, value pairs easy. Think of it like a global Hash stored in your database, that uses simple ActiveRecord like methods for manipulation. Keep track of any global setting that you don't want to hard code into your Rails application.

[![Gem Version](https://badge.fury.io/rb/rails-settings-cached.svg)](https://rubygems.org/gems/rails-settings-cached) [![build](https://github.com/huacnlee/rails-settings-cached/workflows/build/badge.svg)](https://github.com/huacnlee/rails-settings-cached/actions?query=workflow%3Abuild)

## Installation

Edit your Gemfile:

```bash
bundle add rails-settings-cached
```

Generate your app settings:

```bash
rails g app_settings:install
```

Will create:
- `app/models/app_setting.rb`
- `db/migrate/create_app_setting.rb`

Or use a custom name for the model (which will also affect the table name):

```bash
rails g app_settings:install AppConfig
```

Will create:
- `app/models/app_config.rb`
- `db/migrate/create_app_configs.rb`

## 🚨 BREAKING CHANGES - v2.10.0
The `RailsSettings` module was renamed to `RailsAppSettings` to avoid name collisions with [`ledermann/rails-settings`](https://github.com/ledermann/rails-settings) modules.
If you were already using `rails-settings-cached` please change your application settings model's base class from `RailsSettings::Base` to `RailsAppSettings::Base` to make sure everything works as expected.

## Important Naming Consideration

### Avoid Naming Your Model `Settings`

If you are using both this gem (`rails-settings-cached`) and the [`ledermann/rails-settings`](https://github.com/ledermann/rails-settings) gem in your project, **do not** name your model `Settings`.

The `ledermann/rails-settings` gem already defines a model named `Settings`, and using the same name for your model will result in **namespace conflicts**. This could lead to unexpected behavior, bugs, and errors in your application.

```rb
class AppSetting < RailsAppSettings::Base
  # cache_prefix { "v1" }

  scope :application do
    field :app_name, default: "Rails App Settings", validates: { presence: true, length: { in: 2..20 } }
    field :host, default: "http://example.com", readonly: true
    field :default_locale, default: "zh-CN", validates: { presence: true, inclusion: { in: %w[zh-CN en jp] } }, option_values: %w[en zh-CN jp], help_text: "Bla bla ..."
    field :admin_emails, type: :array, default: %w[admin@rubyonrails.org]

    # lambda default value
    field :welcome_message, type: :string, default: -> { "welcome to #{self.app_name}" }, validates: { length: { maximum: 255 } }
    # Override array separator, default: /[\n,]/ split with \n or comma.
    field :tips, type: :array, separator: /[\n]+/
  end

  scope :limits do
    field :user_limits, type: :integer, default: 20
    field :exchange_rate, type: :float, default: 0.123
    field :captcha_enable, type: :boolean, default: true
  end

  field :notification_options, type: :hash, default: {
    send_all: true,
    logging: true,
    sender_email: "foo@bar.com"
  }

  field :readonly_item, type: :integer, default: 100, readonly: true
end
```

You must use the `field` method to statement the app setting keys, otherwise you can't use it.

The `scope` method allows you to group the keys for admin UI.

Now just run that migration:

```bash
rails db:migrate
```

## Usage

The syntax is easy. First, let's create some settings to keep track of:

```ruby
irb > AppSetting.host
"http://example.com"
irb > AppSetting.app_name
"Rails App Settings"
irb > AppSetting.app_name = "Rails App Settings"
irb > AppSetting.app_name
"Rails App Settings"

irb > AppSetting.user_limits
20
irb > AppSetting.user_limits = "30"
irb > AppSetting.user_limits
30
irb > AppSetting.user_limits = 45
irb > AppSetting.user_limits
45

irb > AppSetting.captcha_enable
1
irb > AppSetting.captcha_enable?
true
irb > AppSetting.captcha_enable = "0"
irb > AppSetting.captcha_enable
false
irb > AppSetting.captcha_enable = "1"
irb > AppSetting.captcha_enable
true
irb > AppSetting.captcha_enable = "false"
irb > AppSetting.captcha_enable
false
irb > AppSetting.captcha_enable = "true"
irb > AppSetting.captcha_enable
true
irb > AppSetting.captcha_enable?
true

irb > AppSetting.admin_emails
["admin@rubyonrails.org"]
irb > AppSetting.admin_emails = %w[foo@bar.com bar@dar.com]
irb > AppSetting.admin_emails
["foo@bar.com", "bar@dar.com"]
irb > AppSetting.admin_emails = "huacnlee@gmail.com,admin@admin.com\nadmin@rubyonrails.org"
irb > AppSetting.admin_emails
["huacnlee@gmail.com", "admin@admin.com", "admin@rubyonrails.org"]

irb > AppSetting.notification_options
{
  send_all: true,
  logging: true,
  sender_email: "foo@bar.com"
}
irb > AppSetting.notification_options = {
  sender_email: "notice@rubyonrails.org"
}
irb > AppSetting.notification_options
{
  sender_email: "notice@rubyonrails.org"
}
```

### Get defined fields

> version 2.3+

```rb
# Get all keys
AppSetting.keys
=> ["app_name", "host", "default_locale", "readonly_item"]

# Get editable keys
AppSetting.editable_keys
=> ["app_name", "default_locale"]

# Get readonly keys
AppSetting.readonly_keys
=> ["host", "readonly_item"]

# Get field
AppSetting.get_field("host")
=> { scope: :application, key: "host", type: :string, default: "http://example.com", readonly: true }
AppSetting.get_field("app_name")
=> { scope: :application, key: "app_name", type: :string, default: "Rails App Settings", readonly: false }
AppSetting.get_field(:user_limits)
=> { scope: :limits, key: "user_limits", type: :integer, default: 20, readonly: false }
# Get field options
AppSetting.get_field("default_locale")[:options]
=> { option_values: %w[en zh-CN jp], help_text: "Bla bla ..." }
```

### Custom type for app setting

> Since: 2.9.0

You can write your custom field type by under `RailsAppSettings::Fields` module.

#### For example

```rb
module RailsAppSettings
  module Fields
    class YesNo < ::RailsAppSettings::Fields::Base
      def serialize(value)
        case value
        when true then "YES"
        when false then "NO"
        else raise StandardError, 'invalid value'
        end
      end

      def deserialize(value)
        case value
        when "YES" then true
        when "NO" then false
        else nil
        end
      end
    end
  end
end
```

Now you can use `yes_no` type in your app setting:

```rb
class AppSetting
  field :custom_item, type: :yes_no, default: 'YES'
end
```

```rb
irb> AppSetting.custom_item = 'YES'
irb> AppSetting.custom_item
true
irb> AppSetting.custom_item = 'NO'
irb> AppSetting.custom_item
false
```

#### Get All defined fields

> version 2.7.0+

You can use `defined_fields` method to get all defined fields in AppSetting.

```rb
# Get editable fields and group by scope
editable_fields = AppSetting.defined_fields
  .select { |field| !field[:readonly] }
  .group_by { |field| field[:scope] }
```

## Validations

You can use `validates` options to special the [Rails Validation](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates) for fields.

```rb
class AppSetting < RailsAppSettings::Base
  # cache_prefix { "v1" }
  field :app_name, default: "Rails App Settings", validates: { presence: true, length: { in: 2..20 } }
  field :default_locale, default: "zh-CN", validates: { presence: true, inclusion: { in: %w[zh-CN en jp], message: "is not included in [zh-CN, en, jp]" } }
end
```

Now validate will work on record save:

```rb
irb> AppSetting.app_name = ""
ActiveRecord::RecordInvalid: (Validation failed: App name can't be blank)
irb> AppSetting.app_name = "Rails App Settings"
"Rails App Settings"
irb> AppSetting.default_locale = "zh-TW"
ActiveRecord::RecordInvalid: (Validation failed: Default locale is not included in [zh-CN, en, jp])
irb> AppSetting.default_locale = "en"
"en"
```

Validate by `save` / `valid?` method:

```rb

setting = AppSetting.find_or_initialize_by(var: :app_name)
setting.value = ""
setting.valid?
# => false
setting.errors.full_messages
# => ["App name can't be blank", "App name too short (minimum is 2 characters)"]

setting = AppSetting.find_or_initialize_by(var: :default_locale)
setting.value = "zh-TW"
setting.save
# => false
setting.errors.full_messages
# => ["Default locale is not included in [zh-CN, en, jp]"]
setting.value = "en"
setting.valid?
# => true
```

## Use AppSetting in Rails initializing:

In `version 2.3+` you can use AppSetting before Rails is initialized.

For example `config/initializers/devise.rb`

```rb
Devise.setup do |config|
  if AppSetting.omniauth_google_client_id.present?
    config.omniauth :google_oauth2, AppSetting.omniauth_google_client_id, AppSetting.omniauth_google_client_secret
  end
end
```

```rb
class AppSetting < RailsAppSettings::Base
  field :omniauth_google_client_id, default: ENV["OMNIAUTH_GOOGLE_CLIENT_ID"]
  field :omniauth_google_client_secret, default: ENV["OMNIAUTH_GOOGLE_CLIENT_SECRET"]
end
```

## Readonly field

You may also want use AppSetting before Rails initialize:

```
config/environments/*.rb
```

If you want do that do that, the app setting field must has `readonly: true`.

For example:

```rb
class AppSetting < RailsAppSettings::Base
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
require_relative "../../app/models/app_setting"

Rails.application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = AppSetting.mailer_options.deep_symbolize_keys
end
```

TIP: You also can follow this file to rewrite ActionMailer's `mail` method for configuration Mail options from AppSetting after Rails booted.

https://github.com/ruby-china/homeland/blob/main/app/mailers/application_mailer.rb#L19

## Caching flow:

```
AppSetting.host -> Check Cache -> Exist - Get value of key for cache -> Return
                   |
                Fetch all key and values from DB -> Write Cache -> Get value of key for cache -> return
                   |
                Return default value or nil
```

In each AppSetting keys call, we will load the cache/db and save in [ActiveSupport::CurrentAttributes](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html) to avoid hit cache/db.

Each key update will expire the cache, so do not add some frequent update key.

## Change cache key

Some times you may need to force update cache, now you can use `cache_prefix`

```ruby
class AppSetting < RailsAppSettings::Base
  cache_prefix { "you-prefix" }
  ...
end
```

In testing, you need add `AppSetting.clear_cache` for each Test case:

```rb
class ActiveSupport::TestCase
  teardown do
    AppSetting.clear_cache
  end
end
```

---

## How to manage AppSettings in the admin interface?

If you want to create an admin interface to editing the AppSettings, you can try methods in following:

config/routes.rb

```rb
namespace :admin do
  resource :app_settings
end
```

app/controllers/admin/app_settings_controller.rb

```rb
module Admin
  class AppSettingsController < ApplicationController
    def create
      @errors = ActiveModel::Errors.new
      setting_params.keys.each do |key|
        next if setting_params[key].nil?

        setting = AppSetting.new(var: key)
        setting.value = setting_params[key].strip
        unless setting.valid?
          @errors.merge!(setting.errors)
        end
      end

      if @errors.any?
        render :new
      end

      setting_params.keys.each do |key|
        AppSetting.send("#{key}=", setting_params[key].strip) unless setting_params[key].nil?
      end

      redirect_to admin_settings_path, notice: "AppSetting was successfully updated."
    end

    private
      def setting_params
        params.require(:app_setting).permit(:host, :user_limits, :admin_emails,
          :captcha_enable, :notification_options)
      end
  end
end
```

app/views/admin/app_settings/show.html.erb

```erb
<%= form_for(AppSetting.new, url: admin_app_settings_path) do |f| %>
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
    <%= f.text_field :host, value: AppSetting.host, class: "form-control", placeholder: "http://localhost"  %>
  </div>

  <div class="form-group form-checkbox">
    <label>
      <%= f.check_box :captcha_enable, checked: AppSetting.captcha_enable? %>
      Enable/Disable Captcha
    </label>
  </div>

  <div class="form-group">
    <label class="control-label">Admin Emails</label>
    <%= f.text_area :admin_emails, value: AppSetting.admin_emails.join("\n"), class: "form-control" %>
  </div>

  <div class="form-group">
    <label class="control-label">Notification options</label>
    <%= f.text_area :notification_options, value: YAML.dump(AppSetting.notification_options), class: "form-control", style: "height: 180px;"  %>
    <div class="form-text">
      Use YAML format to config the SMTP_html
    </div>
  </div>

  <div>
    <%= f.submit 'Update AppSettings' %>
  </div>
<% end %>
```

## Special Cache Storage

You can use `cache_store` to change cache storage, default is `Rails.cache`.

Add `config/initializers/rails_app_settings.rb`

```rb
RailsAppSettings.configure do
  self.cache_storage = ActiveSupport::Cache::RedisCacheStore.new(url: "redis://localhost:6379")
end
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
- [texterify/texterify](https://github.com/texterify/texterify) - 2.x
- [mastodon/mastodon](https://github.com/mastodon/mastodon) - 0.6.x
- [helpyio/helpy](https://github.com/helpyio/helpy) - 0.5.x
- [maybe-finance/maybe](https://github.com/maybe-finance/maybe) - 2.x

And more than [1K repositories](https://github.com/huacnlee/rails-settings-cached/network/dependents) used.
