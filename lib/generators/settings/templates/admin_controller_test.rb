require 'test_helper'

module Admin
  class SettingsControllerTest < ActionDispatch::IntegrationTest
    test 'should get show' do
      get admin_settings_path
      assert_response :success
    end

    # Setting.field :app_name, default: 'App'
    test 'should update settings' do
      post admin_settings_path, params: {
        setting: {
          app_name: 'New App Name'
        }
      }

      assert_redirected_to admin_settings_path
      assert_equal 'Settings updated successfully', flash[:notice]
      assert_equal 'New App Name', Setting.app_name
    end

    # Setting.field :user_limit, type: :integer, default: 10, validates: { numericality: true }
    test 'should show errors for invalid settings' do
      post admin_settings_path, params: {
        setting: {
          user_limit: 'invalid'
        }
      }

      assert_response :success
      assert_select 'li', /is not a number/
    end

    # Setting.field :api_key, default: 'secret', readonly: true
    test 'should not update readonly settings' do
      assert_raises(NoMethodError) do
        post admin_settings_path, params: {
          setting: {
            api_key: 'new_value'
          }
        }
      end

      assert_equal 'secret', Setting.api_key
    end
  end
end
