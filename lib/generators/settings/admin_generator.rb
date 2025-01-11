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
  end
end
