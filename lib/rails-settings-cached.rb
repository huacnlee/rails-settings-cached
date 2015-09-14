require_relative 'rails-settings/settings'
require_relative 'rails-settings/cached_settings'
require_relative 'rails-settings/scoped_settings'
require_relative 'rails-settings/extend'

class RailsSettings::Railtie < Rails::Railtie
  initializer "rails_settings.active_record.initialization" do
    RailsSettings::CachedSettings.after_commit :rewrite_cache, on: %i(create update)
    RailsSettings::CachedSettings.after_commit :expire_cache, on: %i(destroy)
  end
end
