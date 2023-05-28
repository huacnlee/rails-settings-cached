module RailsSettings
  module Fields
    class Integer < ::RailsSettings::Fields::Base
      def convert_to_value(value)
        value.to_i
      end
    end
  end
end
