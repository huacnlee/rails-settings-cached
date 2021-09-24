module RailsSettings
  module RequestCacheGetter
    extend ActiveSupport::Concern

    class_methods do
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

  if defined? ActiveSupport::CurrentAttributes
    # For storage all settings in Current, it will reset after per request completed.
    # Base on ActiveSupport::CurrentAttributes
    # https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html
    class RequestCache < ActiveSupport::CurrentAttributes
      include RequestCacheGetter
      attribute :settings
    end
  else
    # https://github.com/steveklabnik/request_store
    # For Rails 5.0
    require "request_store"

    class RequestCache
      include RequestCacheGetter

      class << self
        def reset
          self.settings = nil
        end

        def settings
          RequestStore.store[:rails_settings_all_settings]
        end

        def settings=(val)
          RequestStore.store[:rails_settings_all_settings] = val
        end
      end
    end
  end
end
