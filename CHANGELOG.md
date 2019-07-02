## 2.0.4

- Fix #166 avoid define method to super class.

## 2.0.0

> 🚨 BREAK CHANGES WARNING:
> rails-settings-cached 2.x has redesign the API, the new version will compatible with the stored setting values by older version.
> But you must read the README.md again, and follow guides to change your Setting model.

- New design release.
- No more `scope` support (RailsSettings::Extend has removed);
- No more YAML file.
- Requuire Ruby 2.5+, Rails 5.0+
- You must use `field` method to statement the setting keys before use.

  For example:

  ```rb
  class Setting < RailsSettings::Base
    field :host, default: "http://example.com"
    field :readonly_item, type: :integer, default: 100, readonly: true
    field :user_limits, type: :integer, default: 1
    field :admin_emails, type: :array, default: %w[admin@rubyonrails.org]
    field :captcha_enable, type: :boolean, default: 1
    field :smtp_settings, type: :hash, default: {
      host: "foo.com",
      username: "foo@bar.com",
      password: "123456"
    }
  end
  ```

- One SQL or Cache hit in each request, even you has multiple of keys call in a page.

  > NOTE: This design will load all settings from db/cache in memory, so I recommend that you do not design a lot of Setting keys (below 1000 keys), and do not store large value。


## Changes logs for 0.x

https://github.com/huacnlee/rails-settings-cached/blob/0.x/CHANGELOG.md
