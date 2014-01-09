require "rails-settings/settings"
require "rails-settings/scoped_settings"
require "rails-settings/cached_settings"
require "rails-settings/extend"
require "rails-settings/configuration"

module RailsSettings
  def self.configure
    raise ArgumentError.new('RailsSettings.configure requires a block.') unless block_given?
    yield RailsSettings::Configuration
  end
end
