# frozen_string_literal: true

require "test_helper"

class BaseTest < ActiveSupport::TestCase
  def find_value(var_name)
    Setting.where(var: var_name).take
  end

  def direct_update_record(var, value)
    record = find_value(var) || Setting.new(var: var)
    record[:value] = value.to_s
    record.save!
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

  test "not exist field" do
    assert_raise(NoMethodError) { Setting.not_exist_method  }
  end

  test "readonly field" do
    assert_equal 100, Setting.readonly_item
    assert_raise(NoMethodError) { Setting.readonly_item = 1  }
    assert_kind_of Hash, Setting.omniauth_google_options
    assert_equal "the-client-id", Setting.omniauth_google_options[:client_id]
    assert_equal "the-client-secret", Setting.omniauth_google_options[:client_secret]
    assert_raise(NoMethodError) { Setting.omniauth_google_options = { foo: 1 }  }
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
    Setting.user_limits = 12
    assert_equal 12, Setting.user_limits
    assert_record_value :user_limits, 12
  end

  test "array field" do
    assert_equal %w[admin@rubyonrails.org], Setting.admin_emails
    assert_no_record :admin_emails
    new_emails = %w[admin@rubyonrails.org huacnlee@gmail.com]
    Setting.admin_emails = new_emails.join("\n")
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
end
