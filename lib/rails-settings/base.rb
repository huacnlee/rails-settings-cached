module RailsSettings
  class Base < Settings
    def rewrite_cache
      Rails.cache.write(cache_key, value)
    end

    def expire_cache
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
        scope.join('/')
      end

      def [](key)
        return super(key) unless rails_initialized?
        val = Rails.cache.fetch(cache_key(key, @object)) do
          super(key)
        end
        val
      end

      # set a setting value by [] notation
      def []=(var_name, value)
        super
        Rails.cache.write(cache_key(var_name, @object), value)
        value
      end
    end
  end
end
