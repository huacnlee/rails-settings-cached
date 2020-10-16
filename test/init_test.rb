# frozen_string_literal: true

require "test_helper"

class InitTest < ActiveSupport::TestCase
  test "use setting before when table does not create" do
    assert_equal "Hello world", NoTableSetting.foo
  end
end
