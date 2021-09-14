# frozen_string_literal: true

require "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  test "GET /" do
    get root_path
    assert_equal 200, response.status
    res = response.parsed_body
    assert_equal "http://example.com", res["host"]
    assert_equal ["admin@rubyonrails.org"], res["admin_emails"]
  end
end
