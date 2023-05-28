module RailsSettings
  module Fields
    class Float < ::RailsSettings::Fields::Base
      def deserialize(value)
        value.to_f
      end

      def serialize(value)
        deserialize(value)
      end
    end
  end
end
