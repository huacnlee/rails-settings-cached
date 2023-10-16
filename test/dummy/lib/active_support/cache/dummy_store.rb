# frozen_string_literal: true

module ActiveSupport
  module Cache
    class DummyStore < Store
      attr_reader :data

      def initialize(options = {})
        super(options)

        @data = {}
      end

      def read_entry(key, **options)
        data[key]
      end

      def write_entry(key, value, **options)
        data[key] = value
      end

      def delete_entry(key, **options)
        data.delete(key)
      end
    end
  end
end
