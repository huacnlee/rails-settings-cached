module RailsSettings
	class CachedSettings < Settings
    after_update :rewrite_cache    
    after_create :rewrite_cache
		def rewrite_cache
			Rails.cache.write("settings:#{self.var}", self.value)
		end
    
   before_destroy { |record| Rails.cache.delete("settings:#{record.var}") }
    

		def self.[](var_name)
			Rails.cache.fetch("settings:#{var_name}") {
				super(var_name)
			}
    end    
	end
end
