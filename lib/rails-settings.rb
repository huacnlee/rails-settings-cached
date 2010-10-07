require "rails-settings/settings"
require "rails-settings/scoped_settings"


require "rails-settings/railtie" if defined?(Rails) && Rails.version >= "3"
