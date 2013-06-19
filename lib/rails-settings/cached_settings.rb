module RailsSettings
	class CachedSettings < Settings
    after_update :rewrite_cache    
    after_create :rewrite_cache

    def self.set_cache_expiration(expires_in)
      @expires_in = expires_in
    end

    def self.get_cache_expiration
      @expires_in ||= 29.days
      @expires_in.to_i
    end

		def rewrite_cache
			Rails.cache.write("settings:#{self.var}", self.value, :expires_in => self.class.get_cache_expiration)
		end
    
   after_destroy { |record| Rails.cache.delete("settings:#{record.var}") }
    

		def self.[](var_name)
      obj = Rails.cache.fetch("settings:#{var_name}", :expires_in => self.get_cache_expiration) do
        super(var_name)

			end
      obj || @@defaults[var_name.to_s]
    end    
    
    def self.save_default(key,value)
      if self.send(key) == nil
        self.send("#{key}=",value)
      end
    end
	end
end
