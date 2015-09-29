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
        scope << "#{scope_object.class.name}-#{scope_object.id}:" if scope_object
        scope << "#{var_name}"
      end

      def [](var_name)
        value = Rails.cache.fetch(cache_key(var_name, @object)) do
          super(var_name)
        end

        if value.nil?
          @@defaults[var_name.to_s] if value.nil?
        else
          value
        end
      end

      def save_default(key, value)
        return false unless self[key].nil?
        self[key] = value
      end
    end
  end
end
