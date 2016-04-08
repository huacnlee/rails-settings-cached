module RailsSettings
  class Settings < Base
    def self.inherited(subclass)
      Kernel.warn 'DEPRECATION WARNING: RailsSettings::Settings is deprecated and it will removed in 0.6.0. ' <<
                  'Please use RailsSettings::Base instead.'
      super(subclass)
    end
  end
end
