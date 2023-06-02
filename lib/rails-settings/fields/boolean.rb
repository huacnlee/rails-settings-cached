module RailsSettings
  module Fields
    class Boolean < ::RailsSettings::Fields::Base
      def deserialize(value)
        return nil if value.nil?

        ["true", "1", 1, true].include?(value)
      end

      def serialize(value)
        deserialize(value)
      end
    end
  end
end
