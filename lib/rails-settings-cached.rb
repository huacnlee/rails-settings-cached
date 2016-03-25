require_relative 'rails-settings/settings'
require_relative 'rails-settings/base'
require_relative 'rails-settings/cached_settings'
require_relative 'rails-settings/scoped_settings'
require_relative 'rails-settings/yml_setting'
require_relative 'rails-settings/extend'
require_relative 'rails-settings/version'

module RailsSettings
  class Railtie < Rails::Railtie
    initializer "rails_settings.active_record.initialization" do
      RailsSettings::Base.after_commit :rewrite_cache, on: %i(create update)
      RailsSettings::Base.after_commit :expire_cache, on: %i(destroy)
    end
  end
end
