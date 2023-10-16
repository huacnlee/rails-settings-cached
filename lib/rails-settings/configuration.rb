# frozen_string_literal: true

module RailsSettings
  class Configuration
    # Caching storage backend.
    # Default: `Rails.cache`
    attr_accessor :cache_storage
  end

  class << self
    def config
      return @config if defined?(@config)

      @config = Configuration.new
      @config.cache_storage = Rails.cache
      @config
    end

    def configure(&block)
      config.instance_exec(&block)
    end
  end
end
