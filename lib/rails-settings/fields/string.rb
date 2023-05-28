module RailsSettings
  module Fields
    class String < ::RailsSettings::Fields::Base
      def deserialize(value)
        value
      end

      def serialize(value)
        deserialize(value)
      end
    end
  end
end
