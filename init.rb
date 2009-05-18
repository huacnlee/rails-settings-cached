require 'settings'

ActiveRecord::Base.class_eval do
  def self.has_settings
    class_eval do
      def settings
        ScopedSettings.for_object(self)
      end
    end
  end
end