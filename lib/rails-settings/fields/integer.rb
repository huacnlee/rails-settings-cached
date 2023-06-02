module RailsSettings
  module Fields
    class Integer < ::RailsSettings::Fields::Base
      def deserialize(value)
        return nil if value.nil?

        value.to_i
      end

      def serialize(value)
        deserialize(value)
      end
    end
  end
end
