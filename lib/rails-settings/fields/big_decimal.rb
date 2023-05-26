require_relative './base'

module RailsSettings
  module Fields
    class BigDecimal < ::RailsSettings::Fields::Base
      def convert_to_value(value)
        value.to_d
      end
    end
  end
end
