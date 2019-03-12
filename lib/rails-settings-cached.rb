require_relative "rails-settings/settings"
require_relative "rails-settings/request_cache"
require_relative "rails-settings/base"
require_relative "rails-settings/scoped_settings"
require_relative "rails-settings/default"
require_relative "rails-settings/extend"
require_relative "rails-settings/railtie"
require_relative "rails-settings/version"

module RailsSettings
  class << self
    # Thread safed cache in Memory
    def request_cache
      RailsSettings::RequestCache.current
    end
  end
end
