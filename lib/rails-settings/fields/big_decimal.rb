module RailsSettings
  module Fields
    class BigDecimal < ::RailsSettings::Fields::Base
      def deserialize(value)
        value.to_d
      end

      def serialize(value)
        deserialize(value)
      end
    end
  end
end
