# frozen_string_literal: true

require_relative "rails-settings/fields/base"
require_relative "rails-settings/fields/array"
require_relative "rails-settings/fields/big_decimal"
require_relative "rails-settings/fields/boolean"
require_relative "rails-settings/fields/float"
require_relative "rails-settings/fields/hash"
require_relative "rails-settings/fields/integer"
require_relative "rails-settings/fields/string"

require_relative "rails-settings/base"
require_relative "rails-settings/configuration"
require_relative "rails-settings/request_cache"
require_relative "rails-settings/middleware"
require_relative "rails-settings/railtie"
require_relative "rails-settings/version"

module RailsSettings
  module Fields
  end
end
