# frozen_string_literal: true

require_relative "rails-app-settings/fields/base"
require_relative "rails-app-settings/fields/array"
require_relative "rails-app-settings/fields/big_decimal"
require_relative "rails-app-settings/fields/boolean"
require_relative "rails-app-settings/fields/float"
require_relative "rails-app-settings/fields/hash"
require_relative "rails-app-settings/fields/integer"
require_relative "rails-app-settings/fields/string"

require_relative "rails-app-settings/base"
require_relative "rails-app-settings/configuration"
require_relative "rails-app-settings/request_cache"
require_relative "rails-app-settings/middleware"
require_relative "rails-app-settings/railtie"
require_relative "rails-app-settings/version"

module RailsAppSettings
  module Fields
  end
end
