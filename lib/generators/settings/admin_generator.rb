module Settings
  class AdminGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def create_controller
      template 'admin_controller.rb', 'app/controllers/admin/settings_controller.rb'
      template 'admin_controller_test.rb', 'test/controllers/admin/settings_controller_test.rb'
    end

    def create_view
      template 'admin_view.html.erb', 'app/views/admin/settings/show.html.erb'
    end

    def add_route
      route "namespace :admin do\n    resource :settings\n  end"
    end

    def inject_test_settings
      inject_into_file 'app/models/setting.rb', after: "cache_prefix { \"v1\" }\n" do
        <<-RUBY

  # These example settings are used in tests
  field :app_name, default: "App"
  field :user_limit, type: :integer, default: 10, validates: { numericality: true }
  field :api_key, default: "secret", readonly: true
        RUBY
      end
    end
  end
end
