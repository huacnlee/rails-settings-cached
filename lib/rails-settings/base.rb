# frozen_string_literal: true

require "request_store"

module RailsSettings
  class Base < ActiveRecord::Base
    class SettingNotFound < RuntimeError; end

    SEPARATOR_REGEXP = /[\n,;]+/
    self.table_name = table_name_prefix + "settings"

    @@setting_names = []

    # get the value field, YAML decoded
    def value
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
        RequestStore.store[:rails_settings_all_settings] = nil
        Rails.cache.delete(self.cache_key)
      end

      def field(key, **opts)
        @@setting_names << key.to_s
        _define_field(key, default: opts[:default], type: opts[:type], readonly: opts[:readonly], separator: opts[:separator])
      end

      def cache_prefix(&block)
        @cache_prefix = block
      end

      def cache_key
        scope = ["rails-settings-cached"]
        scope << @cache_prefix.call if @cache_prefix
        scope.join("/")
      end

      def setting_names
        @@setting_names
      end

      private

        def _define_field(key, default: nil, type: :string, readonly: false, separator: nil)
          if readonly
            define_singleton_method(key) do
              self.send(:_covert_string_to_typeof_value, type, default, separator: separator)
            end
          else
            define_singleton_method(key) do
              val = self.send(:_value_of, key)
              result = nil
              if !val.nil?
                result = val
              else
                result = default
                result = default.call if default.is_a?(Proc)
              end

              result = self.send(:_covert_string_to_typeof_value, type, result, separator: separator)

              result
            end

            define_singleton_method("#{key}=") do |value|
              var_name = key.to_s

              record = find_by(var: var_name) || new(var: var_name)
              value = self.send(:_covert_string_to_typeof_value, type, value, separator: separator)

              record.value = value
              record.save!

              value
            end
          end

          if type == :boolean
            define_singleton_method("#{key}?") do
              self.send(key)
            end
          end
        end

        def _covert_string_to_typeof_value(type, value, separator: nil)
          return value unless [String, Integer, Float, BigDecimal].include?(value.class)

          case type
          when :boolean
            value == "true" || value == "1" || value == 1 || value == true
          when :array
            value.split(separator || SEPARATOR_REGEXP).reject { |str| str.empty? }.map(&:strip)
          when :hash
            value = YAML.load(value).to_h rescue eval(value).to_h rescue {}
            value.deep_stringify_keys!
            value
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
          raise "#{self.table_name} does not exist." unless table_exists?

          _all_settings[var_name.to_s]
        end

        def rails_initialized?
          Rails.application && Rails.application.initialized?
        end

        def _all_settings
          raise "You cannot use settings before Rails initialize." unless rails_initialized?
          RequestStore.store[:rails_settings_all_settings] ||= begin
            Rails.cache.fetch(self.cache_key, expires_in: 1.week) do
              vars = unscoped.select("var, value")
              result = {}
              vars.each { |record| result[record.var] = record.value }
              result.with_indifferent_access
            end
          end
        end
    end
  end
end
