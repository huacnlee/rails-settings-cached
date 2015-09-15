module RailsSettings
  class CachedSettings < Settings
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
      def cache_key(var_name, scope_object)
        scope = "rails_settings_cached:"
        if scope_object
          klass = scope_object.class
          primary_key = klass.primary_key
          id = scope_object.public_send(primary_key)
          scope << "#{klass.base_class.name}-#{id}:"
        end
        scope << "#{var_name}"
      end

      def [](var_name)
        obj = Rails.cache.read(cache_key(var_name, @object))
        obj = super(var_name) if obj.nil?

        return @@defaults[var_name.to_s] if obj.nil?
        obj
      end

      def save_default(key, value)
        return false unless self[key].nil?
        self[key] = value
      end
    end
  end
end
