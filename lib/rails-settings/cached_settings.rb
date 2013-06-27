module RailsSettings
  class CachedSettings < Settings

    def self.cache_store
      Rails.cache
    end

    after_update :rewrite_cache    
    after_create :rewrite_cache
    def rewrite_cache
      self.class.cache_store.write("settings:#{self.var}", self.value)      
    end
    
    after_destroy { |record| record.class.cache_store.delete("settings:#{record.var}") }
    
    def self.[](var_name)
      cache_key = "settings:#{var_name}"
      obj = cache_store.fetch(cache_key) {
        super(var_name)
      }
      obj == nil ? @@defaults[var_name.to_s] : obj
    end    
    
    def self.save_default(key,value)
      if self.send(key) == nil
        self.send("#{key}=",value)
      end
    end
  end
end
