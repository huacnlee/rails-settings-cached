# frozen_string_literal: true

module RailsSettings
  class Base < ActiveRecord::Base
    PROTECTED_KEYS = %w[var value]
    self.table_name = table_name_prefix + "settings"

    after_commit :clear_cache, on: %i[create update destroy]

    # get the value field, YAML decoded
    def value
      # rubocop:disable Security/YAMLLoad
      payload = self[:value]

      if payload.present?
        YAML.respond_to?(:unsafe_load) ? YAML.unsafe_load(payload) : YAML.load(payload)
      end
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
        cache_storage.delete(cache_key)
      end

      def field(key, **opts)
        _define_field(key, **opts)
      end

      alias_method :_rails_scope, :scope
      def scope(*args, &block)
        name = args.shift
        body = args.shift
        if body.respond_to?(:call)
          return _rails_scope(name, body, &block)
        end

        @scope = name.to_sym
        yield block
        @scope = nil
      end

      def get_field(key)
        @defined_fields.find { |field| field.key == key.to_s }.to_h || {}
      end

      def cache_prefix(&block)
        @cache_prefix = block
      end

      def cache_key
        key_parts = ["rails-settings-cached"]
        key_parts << @cache_prefix.call if @cache_prefix
        key_parts.join("/")
      end

      def keys
        @defined_fields.map(&:key)
      end

      def editable_keys
        @defined_fields.reject(&:readonly).map(&:key)
      end

      def readonly_keys
        @defined_fields.select(&:readonly).map(&:key)
      end

      attr_reader :defined_fields

      private

      def _define_field(key, default: nil, type: :string, readonly: false, separator: nil, validates: nil, **opts)
        key = key.to_s

        raise ProtectedKeyError.new(key) if PROTECTED_KEYS.include?(key)

        field = ::RailsSettings::Fields::Base.generate(
          scope: @scope, key: key, default: default,
          type: type, readonly: readonly, options: opts,
          separator: separator, parent: self
        )
        @defined_fields ||= []
        @defined_fields << field

        define_singleton_method(key) { field.read }

        unless readonly
          define_singleton_method("#{key}=") { |value| field.save!(value: value) }

          if validates
            validates[:if] = proc { |item| item.var.to_s == key }
            send(:validates, key, **validates)
            define_method(:read_attribute_for_validation) { |_key| self.value }
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

      def rails_initialized?
        Rails.application&.initialized?
      end

      def _all_settings
        RequestCache.all_settings ||= cache_storage.fetch(cache_key, expires_in: 1.week) do
          vars = unscoped.select("var, value")
          result = {}
          vars.each { |record| result[record.var] = record.value }
          result.with_indifferent_access
        end
      end

      def cache_storage
        RailsSettings.config.cache_storage
      end
    end
  end
end
