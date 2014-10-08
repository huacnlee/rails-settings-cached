module RailsSettings
  class CachedSettings < Settings
    after_commit :rewrite_cache, on: [:create, :update]
    def rewrite_cache
      Rails.cache.write("settings:#{self.var}", self.value)
    end

    after_commit :expire_cache, on: [:destroy]
    def expire_cache
      Rails.cache.delete("settings:#{self.var}")
    end
    
    def self.[](var_name)
      cache_key = "settings:#{var_name}"
      obj = Rails.cache.read(cache_key)
      if obj == nil
        obj = super(var_name)
      end
      
      return @@defaults[var_name.to_s] if obj == nil
      obj
    end

    def self.save_default(key,value)
      return false if self.send(key) != nil
      self.send("#{key}=",value)
    end
  end
end
