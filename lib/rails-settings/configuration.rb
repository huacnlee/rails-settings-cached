# frozen_string_literal: true

module RailsSettings
  InvalidConfigurationError = Class.new(StandardError)

  class Configuration
    attr_reader :storage

    def initialize
      @storage = Rails.cache
    end

    def storage=(value)
      unless value.is_a?(ActiveSupport::Cache::Store)
        raise InvalidConfigurationError, <<~TXT
          Option `storage` must be an instance of `ActiveSupport::Cache::Store` class.
        TXT
      end

      @storage = value
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
