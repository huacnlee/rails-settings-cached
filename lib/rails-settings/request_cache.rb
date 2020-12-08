module RailsSettings
  if defined? ActiveSupport::CurrentAttributes 
    # For storage all settings in Current, it will reset after per request completed.
    # Base on ActiveSupport::CurrentAttributes
    # https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html
    class RequestCache < ActiveSupport::CurrentAttributes 
      attribute :settings
    end
  else
    # https://github.com/steveklabnik/request_store
    # For Rails 5.0
    require "request_store"

    class RequestCache
      class << self
        def reset
          self.settings = nil
        end

        def settings
          RequestStore.store[:rails_settings_all_settings]
        end

        def settings=(val)
          RequestStore.store[:rails_settings_all_settings]
        end
      end
    end
  end
end