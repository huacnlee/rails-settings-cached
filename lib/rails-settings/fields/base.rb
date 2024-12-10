module RailsSettings
  module Fields
    class Base < Struct.new(:scope, :key, :default, :parent, :readonly, :separator, :type, :options, keyword_init: true)
      SEPARATOR_REGEXP = /[\n,;]+/

      def initialize(scope:, key:, default:, parent:, readonly:, separator:, type:, options:)
        super
        self.readonly = !!readonly
        self.type ||= :string
        self.separator ||= SEPARATOR_REGEXP
      end

      def save!(value:)
        serialized_value = serialize(value)
        parent_record = parent.find_by(var: key) || parent.new(var: key)
        parent_record.value = serialized_value
        parent_record.save!
        parent_record.value
      end

      def saved_value
        return parent.send(:_all_settings)[key] if table_exists?

        # Fallback to default value if table was not ready (before migrate)
        puts(
          "WARNING: table: \"#{parent.table_name}\" does not exist or not database connection, `#{parent.name}.#{key}` fallback to returns the default value."
        )
        nil
      end

      def default_value
        default.is_a?(Proc) ? default.call : default
      end

      def read
        stored_value = saved_value
        return deserialize(default_value) if readonly || stored_value.nil?
        deserialize(stored_value)
      end

      def deserialize(value)
        raise NotImplementedError
      end

      def serialize(value)
        raise NotImplementedError
      end

      def to_h
        super.slice(:scope, :key, :default, :type, :readonly, :options)
      end

      def table_exists?
        parent.table_exists?
      rescue StandardError
        false
      end

      class << self
        def generate(**args)
          fetch_field_class(args[:type]).new(**args)
        end

        private

        def fetch_field_class(type)
          field_class_name = type.to_s.split("_").map(&:capitalize).join("")
          begin
            const_get("::RailsSettings::Fields::#{field_class_name}")
          rescue StandardError
            ::RailsSettings::Fields::String
          end
        end
      end
    end
  end
end
