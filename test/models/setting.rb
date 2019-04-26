# frozen_string_literal: true

class Setting < RailsSettings::Base
  cache_prefix { "v1" }

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
  field :omniauth_google_options, default: {
    client_id: "the-client-id",
    client_secret: "the-client-secret",
  }, type: :string, readonly: true
end
