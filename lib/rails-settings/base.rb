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
      def cache_prefix_by_startup
        @cache_prefix_by_startup ||= Time.now.to_f.to_s
      end

      def cache_prefix(&block)
        @cache_prefix = block
      end

      def cache_key(var_name, scope_object)
        scope = ["rails_settings_cached", cache_prefix_by_startup]
        scope << @cache_prefix.call if @cache_prefix
        scope << "#{scope_object.class.name}-#{scope_object.id}" if scope_object
        scope << var_name.to_s
        scope.join('/')
      end

      def [](key)
        val = Rails.cache.fetch(cache_key(key, @object)) do
          super(key)
        end
        val
      end

      # set a setting value by [] notation
      def []=(var_name, value)
        super

        Rails.cache.write(cache_key(var_name, @object),value)

        value
      end

      def save_default(key, value)
        Kernel.warn 'DEPRECATION WARNING: RailsSettings save_default is deprecated and it will removed in 0.7.0. ' <<
                    'Please use YAML file for default setting.'
        return false unless self[key].nil?
        self[key] = value
      end
    end
  end
end
