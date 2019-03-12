module RailsSettings
  class RequestCache < ActiveSupport::Cache::Store
    class << self
      def current
        @current ||= RequestCache.new
      end
    end

    def initialize(options = nil)
      options ||= {}
      super(options)
      @monitor = Monitor.new
    end

    def data
      Thread.current[:rails_settings_request_cache] ||= {}
    end

    def clear
      data.clear
    end

    # Synchronize calls to the cache. This should be called wherever the underlying cache implementation
    # is not thread safe.
    def synchronize(&block) # :nodoc:
      @monitor.synchronize(&block)
    end

    protected

      def read_entry(key, options) # :nodoc:
        data[key]
      end

      def write_entry(key, entry, options) # :nodoc:
        entry.dup_value!
        synchronize do
          old_entry = data[key]
          return false if data.key?(key) && options[:unless_exist]
          data[key] = entry
          true
        end
      end

      def delete_entry(key, options) # :nodoc:
        synchronize do
          entry = data.delete(key)
          !!entry
        end
      end

  end
end
