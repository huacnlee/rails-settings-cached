module RailsSettings
  module Fields
    class String < ::RailsSettings::Fields::Base
      def deserialize(value)
        return nil if value.nil?

        value
      end

      def serialize(value)
        deserialize(value)
      end
    end
  end
end
