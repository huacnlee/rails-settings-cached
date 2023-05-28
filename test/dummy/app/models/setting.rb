# frozen_string_literal: true

class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  scope :ordered, -> { order(id: :desc) }
  scope :by_prefix, ->(key) { where("var like ?", "#{key}%") } do
    def foo
      "foo"
    end
  end

  scope :application do
    field :host, default: "http://example.com", validates: {presence: true}
    field :admin_emails, type: :array, default: %w[admin@rubyonrails.org]
    field :captcha_enable, type: :boolean, default: true
    field :user_limits, type: :integer, default: 1, validates: {presence: true, format: {with: /\d+/, message: "must be numbers"}}
  end

  scope :contents do
    field :tips, type: :array, separator: /\n+/
    field :default_tags, type: :array, separator: /[\s,]+/, default: []
    field :float_item, type: :float, default: 7
    field :big_decimal_item, type: :big_decimal, default: 9
    field :default_value_with_block, type: :integer, default: -> { 1 + 1 }
    field :custom_item, type: :custom, default: 1
  end

  scope :mailer do
    field :mailer_provider, default: "smtp", validates: {presence: true, inclusion: {in: %w[smtp sendmail sendgrid]}}
    field :smtp_settings, type: :hash, default: {
      host: "foo.com",
      username: "foo@bar.com",
      password: "123456"
    }
  end

  scope :readonly do
    field :readonly_item, type: :integer, default: 100, readonly: true
    field :readonly_item_with_proc, type: :integer, default: -> { readonly_item + 3 }, readonly: true
  end

  scope :omniauth do
    field :omniauth_google_options, default: {
      client_id: "the-client-id",
      client_secret: "the-client-secret"
    }, type: :hash, readonly: true
  end

  field :key_with_more_options, type: :array, validates: {presence: true}, default: %w[foo bar], foo: 1, section: :theme
end
