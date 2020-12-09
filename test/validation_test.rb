# frozen_string_literal: true

require "test_helper"

class ValidationTest < ActiveSupport::TestCase
  test "validation" do
    setting = Setting.find_or_initialize_by(var: "host")
    assert_equal false, setting.valid?
    assert_equal 1, setting.errors.size
    assert_errors_on setting, :host, "Host can't be blank"
    setting.value = "https://ruby-china.org"
    assert_equal true, setting.valid?
    assert_equal 0, setting.errors.size

    setting = Setting.find_or_initialize_by(var: "user_limits")
    assert_equal false, setting.valid?
    assert_equal 2, setting.errors.size
    assert_errors_on setting, :user_limits, ["User limits can't be blank", "User limits must be numbers"]
    setting.value = "hello"
    assert_equal false, setting.valid?
    assert_errors_on setting, :user_limits, ["User limits must be numbers"]
    setting.value = "100"
    assert_equal true, setting.valid?
    assert_equal 0, setting.errors.size

    setting = Setting.find_or_initialize_by(var: "mailer_provider")
    assert_equal false, setting.valid?
    assert_equal 2, setting.errors.size
    assert_errors_on setting, :mailer_provider, ["Mailer provider can't be blank", "Mailer provider is not included in the list"]
    setting.value = "hello"
    assert_equal false, setting.valid?
    assert_equal 1, setting.errors.size
    assert_errors_on setting, :mailer_provider, ["Mailer provider is not included in the list"]
    setting.value = "smtp"
    assert_equal true, setting.valid?
    assert_equal 0, setting.errors.size
  end

  test "validation with assignment" do
    assert_raise_with_validation_message("Validation failed: Host can't be blank") do
      Setting.host = ""
    end
    assert_nothing_raised do
      Setting.host = "foo"
    end

    assert_raise_with_validation_message("Validation failed: Mailer provider is not included in the list") do
      Setting.mailer_provider = "foo"
    end
    assert_nothing_raised do
      Setting.host = "smtp"
    end
  end
end

def assert_raise_with_validation_message(message)
  ex = assert_raise(ActiveRecord::RecordInvalid) {yield}
  assert_equal message, ex.message
end