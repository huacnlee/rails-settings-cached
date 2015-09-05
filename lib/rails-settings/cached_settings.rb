module RailsSettings
  class CachedSettings < Settings
    after_commit :rewrite_cache, on: %i(create update)
    def rewrite_cache
      Rails.cache.write("rails_settings_cached:#{var}", value)
    end

    after_commit :expire_cache, on: %i(destroy)
    def expire_cache
      Rails.cache.delete("rails_settings_cached:#{var}")
    end

    class << self
      def [](var_name)
        cache_key = "rails_settings_cached:#{var_name}"
        obj = Rails.cache.read(cache_key)
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
