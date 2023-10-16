# frozen_string_literal: true

module ActiveSupport
  module Cache
    class DummyStore < Store
      attr_reader :data

      def initialize(options = {})
        super(options)

        @data = {}
      end

      def read_entry(key, _options)
        data[key]
      end

      def write_entry(key, value, _options)
        data[key] = value
      end

      def delete_entry(key, _options)
        data.delete(key)
      end
    end
  end
end
