require_relative './base'

module RailsSettings
  module Fields
    class Boolean < ::RailsSettings::Fields::Base
      def convert_to_value(value)
        ["true", "1", 1, true].include?(value)
      end
    end
  end
end
