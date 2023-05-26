require_relative './base'

module RailsSettings
  module Fields
    class String < ::RailsSettings::Fields::Base
      def convert_to_value(value)
        value
      end
    end
  end
end
