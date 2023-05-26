require_relative './base'

module RailsSettings
  module Fields
    class Hash < ::RailsSettings::Fields::Base
      def convert_to_value(value)
        return value unless value.kind_of?(::String)
        load_value(value).deep_stringify_keys.with_indifferent_access
      end

      def load_value(value)
        YAML.safe_load(value).to_h
      rescue
        {}
      end
    end
  end
end
