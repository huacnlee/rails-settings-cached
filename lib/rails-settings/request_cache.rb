module RailsSettings
  # For storage all settings in Current, it will reset after per request completed.
  # Base on ActiveSupport::CurrentAttributes
  # https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html
  class RequestCache < ActiveSupport::CurrentAttributes
    attribute :settings

    class << self
      def enable!
        Thread.current[:rails_settings_request_cache_enable] = true
      end

      def disable!
        Thread.current[:rails_settings_request_cache_enable] = nil
      end

      def enabled?
        Thread.current[:rails_settings_request_cache_enable]
      end

      def all_settings
        enabled? ? settings : nil
      end

      def all_settings=(val)
        self.settings = val
      end
    end
  end
end
