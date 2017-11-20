require_relative 'rails-settings/settings'
require_relative 'rails-settings/base'
require_relative 'rails-settings/cached_settings'
require_relative 'rails-settings/scoped_settings'
require_relative 'rails-settings/default'
require_relative 'rails-settings/extend'
require_relative 'rails-settings/version'

module RailsSettings
end

require_relative 'rails-settings/railtie' if defined?(Rails)
