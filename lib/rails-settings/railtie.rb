# frozen_string_literal: true

module RailsSettings
  class Railtie < Rails::Railtie
    initializer "rails_settings.configure_rails_initialization" do |app|
      app.middleware.use RailsSettings::Middleware
    end
  end
end
