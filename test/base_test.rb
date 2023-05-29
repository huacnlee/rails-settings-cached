# frozen_string_literal: true

require "test_helper"

# rubocop:disable Lint/ConstantDefinitionInBlock
class BaseTest < ActiveSupport::TestCase
  def find_value(var_name)
    Setting.where(var: var_name).take
  end

  def direct_update_record(var, value)
    record = find_value(var) || Setting.new(var: var)
    record[:value] = YAML.dump(value)
    record.save!(validate: false)
  end

  def assert_no_record(var)
    record = find_value(:admin_emails)
    assert_nil record, message: "#{var} should not have database record."
  end

  def assert_record_value(var, val)
    record = find_value(var)
    assert_not_nil record
    assert_equal val.to_yaml, record[:value]
    assert_equal val, record.value
  end

  test "define setting with protected keys" do
    assert_raise(RailsSettings::ProtectedKeyError, "Can't use var as setting key.") do
      class NewSetting < RailsSettings::Base
        field :var
      end
    end

    assert_raise(RailsSettings::ProtectedKeyError, "Can't use value as setting key.") do
      class NewSetting < RailsSettings::Base
        field :value
      end
    end
  end

  test "cache_prefix and cache_key" do
    assert_equal "rails-settings-cached/v1", Setting.cache_key
    Setting.cache_prefix { "v2" }
    assert_equal "rails-settings-cached/v2", Setting.cache_key
  end

  test "all_settings" do
    assert_equal({}, Setting.send(:_all_settings))
  end

  test "setting_keys" do
    assert_equal 16, Setting.keys.size
    assert_includes(Setting.keys, "host")
    assert_includes(Setting.keys, "readonly_item")
    assert_includes(Setting.keys, "default_tags")
    assert_includes(Setting.keys, "omniauth_google_options")

    assert_equal 13, Setting.editable_keys.size
    assert_includes(Setting.editable_keys, "host")
    assert_includes(Setting.editable_keys, "default_tags")

    assert_equal 3, Setting.readonly_keys.size
    assert_includes(Setting.readonly_keys, "readonly_item")
    assert_includes(Setting.readonly_keys, "readonly_item_with_proc")
    assert_includes(Setting.readonly_keys, "omniauth_google_options")
  end

  test "get_field" do
    assert_equal({}, Setting.get_field("foooo"))
    assert_equal(
      {scope: :application, key: "host", default: "http://example.com", type: :string, readonly: false, options: {}},
      Setting.get_field("host")
    )
    assert_equal(
      {scope: :omniauth, key: "omniauth_google_options", default: {client_id: "the-client-id", client_secret: "the-client-secret"}, type: :hash, readonly: true, options: {}},
      Setting.get_field("omniauth_google_options")
    )
  end

  test "defined_fields and scope" do
    scopes = Setting.defined_fields.select { |field| !field[:readonly] }.group_by { |field| field[:scope] || :none }
    # assert_equal 2, groups.length
    assert_equal %i[application contents mailer none], scopes.keys
    assert_equal 4, scopes[:application].length
    assert_equal 6, scopes[:contents].length
    assert_equal 2, scopes[:mailer].length
  end

  test "not exist field" do
    assert_raise(NoMethodError) { Setting.not_exist_method }
  end

  test "readonly field" do
    assert_equal 100, Setting.readonly_item
    assert_raise(NoMethodError) { Setting.readonly_item = 1 }
    assert_equal 103, Setting.readonly_item_with_proc
    assert_kind_of Hash, Setting.omniauth_google_options
    assert_equal "the-client-id", Setting.omniauth_google_options[:client_id]
    assert_equal "the-client-secret", Setting.omniauth_google_options[:client_secret]
    assert_raise(NoMethodError) { Setting.omniauth_google_options = {foo: 1} }
  end

  test "instance method get field" do
    setting = Setting.new
    assert_equal Setting.host, setting.host
    assert_equal Setting.default_tags, setting.default_tags
    assert_equal Setting.readonly_item, setting.readonly_item
    assert_equal 103, setting.readonly_item_with_proc
  end

  test "value serialize" do
    assert_equal 1, Setting.user_limits
    Setting.user_limits = 12
    assert_equal 12, Setting.user_limits
    assert_record_value :user_limits, 12
  end

  test "string field" do
    assert_equal "http://example.com", Setting.host
    Setting.host = "https://www.example.com"
    assert_equal "https://www.example.com", Setting.host
    Setting.host = "https://www.rubyonrails.org"
    assert_equal "https://www.rubyonrails.org", Setting.host
  end

  test "integer field" do
    assert_equal 1, Setting.user_limits
    assert_instance_of Integer, Setting.user_limits
    assert_no_record :user_limits

    Setting.user_limits = 12
    assert_equal 12, Setting.user_limits
    assert_instance_of Integer, Setting.user_limits
    assert_record_value :user_limits, 12

    Setting.user_limits = "27"
    assert_equal 27, Setting.user_limits
    assert_instance_of Integer, Setting.user_limits
    assert_record_value :user_limits, 27

    Setting.user_limits = 2.7
    assert_equal 2, Setting.user_limits
    assert_instance_of Integer, Setting.user_limits
    assert_record_value :user_limits, 2

    assert_equal 2, Setting.default_value_with_block
    Setting.default_value_with_block = 100
    assert_equal 100, Setting.default_value_with_block
  end

  test "float field" do
    assert_equal 7, Setting.float_item
    assert_instance_of Float, Setting.float_item
    assert_no_record :float_item

    Setting.float_item = 9
    assert_equal 9, Setting.float_item
    assert_instance_of Float, Setting.float_item
    assert_record_value :float_item, 9.to_f

    Setting.float_item = 2.9
    assert_equal 2.9, Setting.float_item
    assert_instance_of Float, Setting.float_item
    assert_record_value :float_item, 2.9

    Setting.float_item = "2.9"
    assert_equal 2.9, Setting.float_item
    assert_instance_of Float, Setting.float_item
    assert_record_value :float_item, "2.9".to_f
  end

  test "big decimal field" do
    assert_equal 9, Setting.big_decimal_item
    assert_instance_of BigDecimal, Setting.big_decimal_item
    assert_no_record :big_decimal_item

    Setting.big_decimal_item = 7
    assert_equal 7, Setting.big_decimal_item
    assert_instance_of BigDecimal, Setting.big_decimal_item
    assert_record_value :big_decimal_item, 7.to_d

    Setting.big_decimal_item = 2.9
    assert_equal 2.9, Setting.big_decimal_item
    assert_instance_of BigDecimal, Setting.big_decimal_item
    assert_record_value :big_decimal_item, 2.9.to_d

    Setting.big_decimal_item = "2.9"
    assert_equal 2.9, Setting.big_decimal_item
    assert_instance_of BigDecimal, Setting.big_decimal_item
    assert_record_value :big_decimal_item, "2.9".to_d
  end

  test "array field" do
    assert_equal %w[admin@rubyonrails.org], Setting.admin_emails
    assert_no_record :admin_emails

    new_emails = %w[admin@rubyonrails.org huacnlee@gmail.com]
    Setting.admin_emails = new_emails
    assert_equal new_emails, Setting.admin_emails
    assert_record_value :admin_emails, new_emails

    Setting.admin_emails = new_emails.join("\n")
    assert_equal new_emails, Setting.admin_emails
    assert_record_value :admin_emails, new_emails

    Setting.admin_emails = new_emails.join(",")
    assert_equal new_emails, Setting.admin_emails
    assert_record_value :admin_emails, new_emails

    Setting.admin_emails = new_emails.join(";")
    assert_equal new_emails, Setting.admin_emails
    assert_record_value :admin_emails, new_emails

    Setting.admin_emails = new_emails.join(" , ")
    assert_equal new_emails, Setting.admin_emails
    assert_record_value :admin_emails, new_emails
  end

  test "hash field" do
    default_value = {
      host: "foo.com",
      username: "foo@bar.com",
      password: "123456"
    }
    assert_equal default_value, Setting.smtp_settings
    assert_no_record :smtp_settings

    # sym keys
    new_value = {
      title: "123",
      name: "456"
    }
    Setting.smtp_settings = new_value
    record = find_value(:smtp_settings)
    assert_equal new_value.deep_stringify_keys, Setting.smtp_settings
    assert_record_value :smtp_settings, new_value

    # string keys
    new_value = {
      "title" => "456",
      "age" => 32,
      "name" => "Jason Lee"
    }
    Setting.smtp_settings = new_value
    assert_equal new_value.deep_stringify_keys, Setting.smtp_settings
    assert_equal "456", Setting.smtp_settings[:title]
    assert_equal "456", Setting.smtp_settings["title"]
    assert_equal 32, Setting.smtp_settings[:age]
    assert_equal 32, Setting.smtp_settings["age"]
    assert_equal "Jason Lee", Setting.smtp_settings[:name]
    assert_equal "Jason Lee", Setting.smtp_settings["name"]
    assert_record_value :smtp_settings, new_value

    # JSON key
    new_value = {
      "sym" => :symbol,
      "str" => "string",
      "num" => 27.72,
      "float" => 9.to_f,
      "big_decimal" => 2.9.to_d
    }
    Setting.smtp_settings = new_value
    assert_equal new_value.deep_stringify_keys, Setting.smtp_settings
    assert_equal :symbol, Setting.smtp_settings[:sym]
    assert_equal :symbol, Setting.smtp_settings["sym"]
    assert_equal "string", Setting.smtp_settings["str"]
    assert_equal "string", Setting.smtp_settings[:str]
    assert_equal 27.72, Setting.smtp_settings["num"]
    assert_equal 9.to_f, Setting.smtp_settings["float"]
    assert_equal 2.9.to_d, Setting.smtp_settings["big_decimal"]
    assert_record_value :smtp_settings, new_value

    Setting.find_by(var: :smtp_settings).update(value: new_value.to_json)
    assert_equal({"sym" => "symbol", "str" => "string", "num" => 27.72, "float" => 9.to_f, "big_decimal" => "2.9"}, Setting.smtp_settings)
    assert_equal "symbol", Setting.smtp_settings[:sym]
    assert_equal "symbol", Setting.smtp_settings["sym"]
  end

  test "boolean field" do
    assert_equal true, Setting.captcha_enable
    assert_no_record :captcha_enable
    Setting.captcha_enable = "0"
    assert_equal false, Setting.captcha_enable
    assert_equal false, Setting.captcha_enable?
    Setting.captcha_enable = "1"
    assert_equal true, Setting.captcha_enable
    assert_equal true, Setting.captcha_enable?
    Setting.captcha_enable = "false"
    assert_equal false, Setting.captcha_enable
    assert_equal false, Setting.captcha_enable?
    Setting.captcha_enable = "true"
    assert_equal true, Setting.captcha_enable
    assert_equal true, Setting.captcha_enable?
    Setting.captcha_enable = 0
    assert_equal false, Setting.captcha_enable
    assert_equal false, Setting.captcha_enable?
    Setting.captcha_enable = 1
    assert_equal true, Setting.captcha_enable
    assert_equal true, Setting.captcha_enable?
    Setting.captcha_enable = false
    assert_equal false, Setting.captcha_enable
    assert_equal false, Setting.captcha_enable?
    Setting.captcha_enable = true
    assert_equal true, Setting.captcha_enable
    assert_equal true, Setting.captcha_enable?
  end

  test "custom field" do
    assert_equal 1, Setting.custom_item
    assert_instance_of Integer, Setting.custom_item
    assert_no_record :custom_item

    Setting.custom_item = 2
    assert_equal 2, Setting.custom_item
    assert_instance_of Integer, Setting.custom_item
    assert_record_value :custom_item, 'b'

    Setting.custom_item = 3
    assert_equal 3, Setting.custom_item
    assert_instance_of Integer, Setting.custom_item
    assert_record_value :custom_item, 'c'

    assert_raise(StandardError) { Setting.custom_item = 4 }
  end

  test "string value in db compatible" do
    # array
    direct_update_record(:admin_emails, "foo@gmail.com,bar@dar.com\naaa@bbb.com")

    assert_equal 3, Setting.admin_emails.length
    assert_kind_of Array, Setting.admin_emails
    assert_equal %w[foo@gmail.com bar@dar.com aaa@bbb.com], Setting.admin_emails

    # integer
    direct_update_record(:user_limits, "100")
    assert_equal 100, Setting.user_limits
    assert_kind_of Integer, Setting.user_limits

    # boolean
    direct_update_record(:captcha_enable, "0")
    assert_equal false, Setting.captcha_enable
    direct_update_record(:captcha_enable, "false")
    assert_equal false, Setting.captcha_enable
    direct_update_record(:captcha_enable, "true")
    assert_equal true, Setting.captcha_enable
    direct_update_record(:captcha_enable, "1")
    assert_equal true, Setting.captcha_enable
  end

  test "array with separator" do
    value = <<~TIP
      Hello this is first line, and have comma.
      This is second line.
    TIP
    direct_update_record(:tips, value)

    assert_equal 2, Setting.tips.length
    assert_equal "Hello this is first line, and have comma.", Setting.tips[0]
    assert_equal "This is second line.", Setting.tips[1]

    value = "Ruby Rails,GitHub"
    direct_update_record(:default_tags, value)
    assert_equal %w[Ruby Rails GitHub], Setting.default_tags
  end

  test "key with complex options" do
    assert_equal %w[foo bar], Setting.key_with_more_options
    field = Setting.get_field(:key_with_more_options)
    assert_equal({scope: nil, key: "key_with_more_options", default: ["foo", "bar"], type: :array, readonly: false, options: {foo: 1, section: :theme}}, field)
  end

  test "rails_scope" do
    assert_kind_of ActiveRecord::Relation, Setting.ordered
    assert_equal %(SELECT "settings".* FROM "settings" ORDER BY "settings"."id" DESC), Setting.ordered.to_sql
    assert_equal %(SELECT "settings".* FROM "settings" WHERE (var like 'readonly_%')), Setting.by_prefix("readonly_").to_sql
    assert_equal "foo", Setting.by_prefix("readonly_").foo
  end
end
