require 'settings'

ActiveRecord::Base.class_eval do
  def self.has_settings
    class_eval do
      def settings
        Settings.scoped_by_object_type_and_object_id(self.class.base_class.to_s, self.id)
      end
    end
  end
end