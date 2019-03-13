module RailsSettings
  class Base < Settings
    def rewrite_cache
      RailsSettings.request_cache.write(cache_key, value)
      Rails.cache.write(cache_key, value)
    end

    def expire_cache
      RailsSettings.request_cache.delete(cache_key)
      Rails.cache.delete(cache_key)
    end

    def cache_key
      self.class.cache_key(var, thing)
    end

    class << self
      def cache_prefix(&block)
        @cache_prefix = block
      end

      def cache_key(var_name, scope_object)
        scope = ["rails_settings_cached"]
        scope << @cache_prefix.call if @cache_prefix
        scope << "#{scope_object.class.name}-#{scope_object.id}" if scope_object
        scope << var_name.to_s
        scope.join("/")
      end

      # Preload all or some key with prefix in Thread.current
      # for avoid multiple hit db/cache in same request
      #
      # Setting.preload!
      # => Fetch all keys from db and save to request cache
      # Setting.foo
      # Setting.bar
      def preload!(starting_with = nil)
        settings = get_all(starting_with)
        settings.each do |key, val|
          RailsSettings.request_cache.write(cache_key(key, @object), val)
        end
      end

      def [](key)
        return super(key) unless rails_initialized?
        full_cache_key = cache_key(key, @object)
        val = RailsSettings.request_cache.fetch(full_cache_key) do
          Rails.cache.fetch(full_cache_key) do
            super(key)
          end
        end

        val
      end

      # set a setting value by [] notation
      def []=(var_name, value)
        super
        RailsSettings.request_cache.write(cache_key(var_name, @object), value)
        Rails.cache.write(cache_key(var_name, @object), value)
        value
      end
    end
  end
end
