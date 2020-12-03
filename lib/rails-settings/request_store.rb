module RailsSettings
  # For storage all settings in Current, it will reset after per request completed.
  # Base on ActiveSupport::CurrentAttributes
  # https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html
  class RequestStore < ActiveSupport::CurrentAttributes 
    attribute :settings
  end
end