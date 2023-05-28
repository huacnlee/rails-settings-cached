module RailsSettings
  module Fields
    class Float < ::RailsSettings::Fields::Base
      def convert_to_value(value)
        value.to_f
      end
    end
  end
end
