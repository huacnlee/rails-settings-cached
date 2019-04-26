# frozen_string_literal: true

module RailsSettings
  class Base < ActiveRecord::Base
    class SettingNotFound < RuntimeError; end

    SEPARATOR_REGEXP = /[\s,]/
    self.table_name = table_name_prefix + "settings"

    # get the value field, YAML decoded
    def value
      YAML.load(self[:value]) if self[:value].present?
    end

    # set the value field, YAML encoded
    def value=(new_value)
      self[:value] = new_value.to_yaml
    end

    def expire_cache
      Thread.current[:rails_settings_all_settings] = nil
      Rails.cache.delete(self.class.cache_key)
    end

    class << self
      def field(key, **opts)
        _define_field(key, default: opts[:default], type: opts[:type], readonly: opts[:readonly])
      end

      def cache_prefix(&block)
        @cache_prefix = block
      end

      def cache_key
        scope = ["rails-settings-cached"]
        scope << @cache_prefix.call if @cache_prefix
        scope.join("/")
      end

      private
        def _define_field(key, default: nil, type: :string, readonly: false)
          self.class.define_method(key) do
            val = self.send(:_value_of, key)
            result = nil
            if !val.nil?
              result = val
            else
              result = default
              result = default.call if default.is_a?(Proc)
            end

            result = self.send(:_covert_string_to_typeof_value, type, result)

            result
          end

          unless readonly
            self.class.define_method("#{key}=") do |value|
              var_name = key.to_s

              record = find_by(var: var_name) || new(var: var_name)
              value = self.send(:_covert_string_to_typeof_value, type, value)

              record.value = value
              record.save!

              value
            end
          end

          if type == :boolean
            self.class.define_method("#{key}?") do
              val = self.send(:_value_of, key)
              val == "true" || val == "1"
            end
          end
        end

        def _covert_string_to_typeof_value(type, value)
          return value unless value.is_a?(String) || value.is_a?(Integer)

          case type
          when :boolean
            return value == "true" || value == "1" || value == 1 || value == true
          when :array
            return value.split(SEPARATOR_REGEXP).reject { |str| str.empty? }
          when :hash
            value = YAML.load(value).to_hash rescue {}
            value.deep_stringify_keys!
            return value
          when :integer
            return value.to_i
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
          raise "You can use settings before Rails initialize." unless rails_initialized?
          Thread.current[:rails_settings_all_settings] ||= begin
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
