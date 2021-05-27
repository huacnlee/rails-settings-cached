# frozen_string_literal: true

require "test_helper"

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

  test "cache_prefix and cache_key" do
    assert_equal "rails-settings-cached/v1", Setting.cache_key
    Setting.cache_prefix { "v2" }
    assert_equal "rails-settings-cached/v2", Setting.cache_key
  end

  test "all_settings" do
    assert_equal({}, Setting.send(:_all_settings))
  end

  test "setting_keys" do
    assert_equal 13, Setting.keys.size
    assert_includes(Setting.keys, "host")
    assert_includes(Setting.keys, "readonly_item")
    assert_includes(Setting.keys, "default_tags")
    assert_includes(Setting.keys, "omniauth_google_options")

    assert_equal 11, Setting.editable_keys.size
    assert_includes(Setting.editable_keys, "host")
    assert_includes(Setting.editable_keys, "default_tags")

    assert_equal 2, Setting.readonly_keys.size
    assert_includes(Setting.readonly_keys, "readonly_item")
    assert_includes(Setting.readonly_keys, "omniauth_google_options")
  end

  test "get_field" do
    assert_equal({}, Setting.get_field("foooo"))
    assert_equal({
                   key: "host", default: "http://example.com", type: :string, readonly: false,
                   metadata: { description: 'Host url' }
                 },
                 Setting.get_field("host"))
    assert_equal(
      { key: "omniauth_google_options", default: { client_id: "the-client-id", client_secret: "the-client-secret" },
        type: :hash, readonly: true, metadata: nil }, Setting.get_field("omniauth_google_options")
    )
  end

  test "not exist field" do
    assert_raise(NoMethodError) { Setting.not_exist_method }
  end

  test "readonly field" do
    assert_equal 100, Setting.readonly_item
    assert_raise(NoMethodError) { Setting.readonly_item = 1 }
    assert_kind_of Hash, Setting.omniauth_google_options
    assert_equal "the-client-id", Setting.omniauth_google_options[:client_id]
    assert_equal "the-client-secret", Setting.omniauth_google_options[:client_secret]
    assert_raise(NoMethodError) { Setting.omniauth_google_options = { foo: 1 } }
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
      "num" => 27.72
    }
    Setting.smtp_settings = new_value
    assert_equal new_value.deep_stringify_keys, Setting.smtp_settings
    assert_equal :symbol, Setting.smtp_settings[:sym]
    assert_equal :symbol, Setting.smtp_settings["sym"]
    assert_equal "string", Setting.smtp_settings["str"]
    assert_equal "string", Setting.smtp_settings[:str]
    assert_equal 27.72, Setting.smtp_settings["num"]
    assert_record_value :smtp_settings, new_value

    Setting.find_by(var: :smtp_settings).update(value: new_value.to_json)
    assert_equal({ "sym" => "symbol", "str" => "string", "num" => 27.72 }, Setting.smtp_settings)
    assert_equal "symbol", Setting.smtp_settings[:sym]
    assert_equal "symbol", Setting.smtp_settings["sym"]

    Setting.smtp_settings = new_value.to_s
    assert_equal new_value.deep_stringify_keys, Setting.smtp_settings
    assert_equal :symbol, Setting.smtp_settings[:sym]
    assert_equal "string", Setting.smtp_settings["str"]
    assert_equal 27.72, Setting.smtp_settings["num"]
    assert_record_value :smtp_settings, ActiveSupport::HashWithIndifferentAccess.new(new_value)

    Setting.smtp_settings = new_value.to_yaml
    assert_equal new_value.deep_stringify_keys, Setting.smtp_settings
    assert_equal :symbol, Setting.smtp_settings[:sym]
    assert_equal "string", Setting.smtp_settings["str"]
    assert_equal 27.72, Setting.smtp_settings["num"]
    assert_record_value :smtp_settings, ActiveSupport::HashWithIndifferentAccess.new(new_value)
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

  test "field retains metadata" do
    assert_equal({ description: "Host url" }, Setting.get_field('host')[:metadata])
  end
end
