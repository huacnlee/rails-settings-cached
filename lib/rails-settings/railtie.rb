# frozen_string_literal: true

module RailsSettings
  class Railtie < Rails::Railtie
    initializer "rails_settings.active_record.initialization" do
      RailsSettings::Base.after_commit :clear_cache, on: %i(create update destroy)
    end
  end
end
