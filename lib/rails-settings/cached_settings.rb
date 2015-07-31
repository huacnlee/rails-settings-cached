module RailsSettings
  class CachedSettings < Settings
    after_commit :rewrite_cache, on: [:create, :update]
    def rewrite_cache
      Rails.cache.write("settings:#{var}", value)
    end

    after_commit :expire_cache, on: [:destroy]
    def expire_cache
      Rails.cache.delete("settings:#{var}")
    end

    class << self
      def [](var_name)
        cache_key = "settings:#{var_name}"
        obj = Rails.cache.read(cache_key)
        obj = super(var_name) if obj.nil?

        return @@defaults[var_name.to_s] if obj.nil?
        obj
      end

      def save_default(key, value)
        return false unless send(key).nil?
        send("#{key}=", value)
      end
    end
  end
end
