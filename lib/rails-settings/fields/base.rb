module RailsSettings
  module Fields
    class Base < Struct.new(:scope, :key, :default, :readonly, :parent, :separator, :type, :options, keyword_init: true)
      SEPARATOR_REGEXP = /[\n,;]+/

      def initialize(scope:, key:, default:, parent:, readonly: false, separator: SEPARATOR_REGEXP, type: :string, options: nil)
        self.readonly = !!readonly
        super
      end

      def save!(value:)
        converted_value = convert_to_value(value)
        parent_record = parent.find_by(var: key) || parent.new(var: key)
        parent_record.value = converted_value
        parent_record.save!
        converted_value
      end

      def saved_value
        parent.send(:_value_of, key)
      end

      def default_value
        default.is_a?(Proc) ? default.call : default
      end

      def convert
        return convert_to_value(default_value) if readonly || saved_value.nil?
        convert_to_value(saved_value)
      end

      def convert_to_value(value)
        raise NotImplementedError
      end

      def to_h
        super.slice(:scope, :key, :default, :type, :readonly, :options)
      end

      class << self
        def generate(**args)
          fetch_field_class(args[:type]).new(**args)
        end

        private

        def fetch_field_class(type)
          field_class_name = type.to_s.split('_').map(&:capitalize).join('')
          const_get("::RailsSettings::Fields::#{field_class_name}")
        end
      end
    end
  end
end
