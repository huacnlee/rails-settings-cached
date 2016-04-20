module RailsSettings
  class Settings < ActiveRecord::Base
    self.table_name = table_name_prefix + 'settings'

    class SettingNotFound < RuntimeError; end

    cattr_accessor :defaults
    @@defaults = {}.with_indifferent_access

    belongs_to :thing, polymorphic: true

    # Support old plugin
    if defined?(SettingsDefaults::DEFAULTS)
      @@defaults = SettingsDefaults::DEFAULTS.with_indifferent_access
    end

    # get the value field, YAML decoded
    def value
      YAML.load(self[:value]) if self[:value].present?
    end

    # set the value field, YAML encoded
    def value=(new_value)
      self[:value] = new_value.to_yaml
    end

    class << self
      # get or set a variable with the variable as the called method
      def method_missing(method, *args)
        method_name = method.to_s
        super(method, *args)
      rescue NoMethodError
        # set a value for a variable
        if method_name[-1] == '='
          var_name = method_name.sub('=', '')
          value = args.first
          self[var_name] = value
        else
          # retrieve a value
          self[method_name]
        end
      end

      # destroy the specified settings record
      def destroy(var_name)
        var_name = var_name.to_s
        obj = object(var_name)
        raise SettingNotFound, "Setting variable \"#{var_name}\" not found" if obj.nil?

        obj.destroy
        true
      end

      # retrieve all settings as a hash (optionally starting with a given namespace)
      def get_all(starting_with = nil)
        vars = thing_scoped.select('var, value')
        vars = vars.where("var LIKE '#{starting_with}%'") if starting_with

        result = {}
        vars.each do |record|
          result[record.var] = record.value
        end
        default_keys = @@defaults.keys
        default_keys = default_keys.select {|k| k.start_with? starting_with } if starting_with
        result.merge! @@defaults.slice(*(default_keys - result.keys))

        result.with_indifferent_access
      end

      def where(sql = nil)
        vars = thing_scoped.where(sql) if sql
        vars
      end

      # get a setting value by [] notation
      def [](var_name)
        object(var_name).try(:value) || @@defaults[var_name.to_s]
      end

      # set a setting value by [] notation
      def []=(var_name, value)
        var_name = var_name.to_s

        record = object(var_name) || thing_scoped.new(var: var_name)
        record.value = value
        record.save!

        value
      end

      def merge!(var_name, hash_value)
        raise ArgumentError unless hash_value.is_a?(Hash)

        old_value = self[var_name] || {}
        raise TypeError, "Existing value is not a hash, can't merge!" unless old_value.is_a?(Hash)

        new_value = old_value.merge(hash_value)
        self[var_name] = new_value if new_value != old_value

        new_value
      end

      def object(var_name)
        thing_scoped.where(var: var_name.to_s).first
      end

      def thing_scoped
        unscoped.where('thing_type is NULL and thing_id is NULL')
      end

      def endabled_yaml?
        @endabled_yaml ||= YMLSetting.source.present?
      end

      def source(filename)
        YMLSetting.source(filename)
      end

      def namespace(env)
        YMLSetting.namespace(env)
      end
    end
  end
end
