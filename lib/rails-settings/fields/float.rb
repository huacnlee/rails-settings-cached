module RailsSettings
  module Fields
    class Float < ::RailsSettings::Fields::Base
      def deserialize(value)
        return nil if value.nil?

        value.to_f
      end

      def serialize(value)
        deserialize(value)
      end
    end
  end
end
