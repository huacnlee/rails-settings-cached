module RailsSettings
	class ThreadCachedSettings < Settings
    after_update :rewrite_cache
    after_create :rewrite_cache
		def rewrite_cache
      Thread.current["settings:#{self.var}"] = self.value
		end

    before_destroy { |record| Thread.current["settings:#{self.var}"] = nil }

		def self.[](var_name)
      Thread.current["settings:#{var_name}"] ||= super(var_name)
    end
	end
end
