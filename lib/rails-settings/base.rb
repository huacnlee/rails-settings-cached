# frozen_string_literal: true

module RailsSettings
  class ProcetedKeyError < RuntimeError
    def initialize(key)
      super("Can't use #{key} as setting key.")
    end
  end

  class Base < ActiveRecord::Base
    SEPARATOR_REGEXP = /[\n,;]+/
    PROTECTED_KEYS = %w[var value]
    self.table_name = table_name_prefix + "settings"

    # get the value field, YAML decoded
    def value
      # rubocop:disable Security/YAMLLoad
      YAML.load(self[:value]) if self[:value].present?
    end

    # set the value field, YAML encoded
    def value=(new_value)
      self[:value] = new_value.to_yaml
    end

    def clear_cache
      self.class.clear_cache
    end

    class << self
      def clear_cache
        RequestCache.reset
        Rails.cache.delete(cache_key)
      end

      def field(key, **opts)
        _define_field(key, **opts)
      end

      def get_field(key)
        @defined_fields.find { |field| field[:key] == key.to_s } || {}
      end

      def cache_prefix(&block)
        @cache_prefix = block
      end

      def cache_key
        scope = ["rails-settings-cached"]
        scope << @cache_prefix.call if @cache_prefix
        scope.join("/")
      end

      def keys
        @defined_fields.map { |field| field[:key] }
      end

      def editable_keys
        @defined_fields.reject { |field| field[:readonly] }.map { |field| field[:key] }
      end

      def readonly_keys
        @defined_fields.select { |field| field[:readonly] }.map { |field| field[:key] }
      end

      attr_reader :defined_fields

      private

      def _define_field(key, default: nil, type: :string, readonly: false, separator: nil, validates: nil, **opts)
        key = key.to_s

        raise ProcetedKeyError.new(key) if PROTECTED_KEYS.include?(key)

        @defined_fields ||= []
        @defined_fields << {
          key: key,
          default: default,
          type: type || :string,
          readonly: readonly.nil? ? false : readonly,
          options: opts
        }

        if readonly
          define_singleton_method(key) do
            result = default.is_a?(Proc) ? default.call : default
            send(:_convert_string_to_typeof_value, type, result, separator: separator)
          end
        else
          define_singleton_method(key) do
            val = send(:_value_of, key)
            result = nil
            if !val.nil?
              result = val
            else
              result = default
              result = default.call if default.is_a?(Proc)
            end

            result = send(:_convert_string_to_typeof_value, type, result, separator: separator)

            result
          end

          define_singleton_method("#{key}=") do |value|
            var_name = key

            record = find_by(var: var_name) || new(var: var_name)
            value = send(:_convert_string_to_typeof_value, type, value, separator: separator)

            record.value = value
            record.save!

            value
          end

          if validates
            validates[:if] = proc { |item| item.var.to_s == key }
            send(:validates, key, **validates)

            define_method(:read_attribute_for_validation) do |_key|
              self.value
            end
          end
        end

        if type == :boolean
          define_singleton_method("#{key}?") do
            send(key)
          end
        end

        # delegate instance get method to class for support:
        # setting = Setting.new
        # setting.admin_emails
        define_method(key) do
          self.class.public_send(key)
        end
      end

      def _convert_string_to_typeof_value(type, value, separator: nil)
        return value unless [String, Integer, Float, BigDecimal].include?(value.class)

        case type
        when :boolean
          ["true", "1", 1, true].include?(value)
        when :array
          value.split(separator || SEPARATOR_REGEXP).reject { |str| str.empty? }.map(&:strip)
        when :hash
          value = begin
            YAML.safe_load(value).to_h
          rescue
            {}
          end
          value.deep_stringify_keys!
          ActiveSupport::HashWithIndifferentAccess.new(value)
        when :integer
          value.to_i
        when :float
          value.to_f
        when :big_decimal
          value.to_d
        else
          value
        end
      end

      def _value_of(var_name)
        unless _table_exists?
          # Fallback to default value if table was not ready (before migrate)
          puts "WARNING: table: \"#{table_name}\" does not exist or not database connection, `#{name}.#{var_name}` fallback to returns the default value."
          return nil
        end

        _all_settings[var_name]
      end

      def _table_exists?
        table_exists?
      rescue
        false
      end

      def rails_initialized?
        Rails.application&.initialized?
      end

      def _all_settings
        RequestCache.settings ||= Rails.cache.fetch(cache_key, expires_in: 1.week) do
          vars = unscoped.select("var, value")
          result = {}
          vars.each { |record| result[record.var] = record.value }
          result.with_indifferent_access
        end
      end
    end
  end
end
