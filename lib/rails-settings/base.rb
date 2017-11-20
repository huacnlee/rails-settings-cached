module RailsSettings
  class Base < Settings
    def rewrite_cache
      self.class.cache_store.write(cache_key, value) unless self.class.no_cache_store?
    end

    def expire_cache
      self.class.cache_store.delete(cache_key) unless self.class.no_cache_store?
    end

    def cache_key
      self.class.cache_key(var, thing)
    end

    class << self
      def cache_store
        Settings.cache_store
      end

      def cache_prefix_by_startup
        return @cache_prefix_by_startup if defined? @cache_prefix_by_startup
        return '' unless Default.enabled?
        @cache_prefix_by_startup = Digest::MD5.hexdigest(Default.instance.to_s)
      end

      def cache_prefix(&block)
        @cache_prefix = block
      end

      def cache_key(var_name, scope_object)
        scope = ['rails_settings_cached', cache_prefix_by_startup]
        scope << @cache_prefix.call if @cache_prefix
        scope << "#{scope_object.class.name}-#{scope_object.id}" if scope_object
        scope << var_name.to_s
        scope.join('/')
      end

      def [](key)
        return super(key) if no_cache_store?
        cache_store.fetch(cache_key(key, @object)) do
          super(key)
        end
      end

      # set a setting value by [] notation
      def []=(var_name, value)
        super
        cache_store.write(cache_key(var_name, @object), value) unless no_cache_store?
        value
      end

      def save_default(key, value)
        Kernel.warn 'DEPRECATION WARNING: RailsSettings save_default is deprecated ' \
                    'and it will removed in 0.7.0. ' \
                    'Please use YAML file for default setting.'
        return false unless self[key].nil?
        self[key] = value
      end
    end
  end
end
