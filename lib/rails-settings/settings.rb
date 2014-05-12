module RailsSettings
  class Settings < ActiveRecord::Base

    self.table_name = table_name_prefix + 'settings'

    class SettingNotFound < RuntimeError; end

    cattr_accessor :defaults
    @@defaults = {}.with_indifferent_access

    # Support old plugin
    if defined?(SettingsDefaults::DEFAULTS)
      @@defaults = SettingsDefaults::DEFAULTS.with_indifferent_access
    end

    #get or set a variable with the variable as the called method
    def self.method_missing(method, *args)
      method_name = method.to_s
      super(method, *args)
    rescue NoMethodError
      #set a value for a variable
      if method_name =~ /=$/
        var_name = method_name.gsub('=', '')
        value = args.first
        self[var_name] = value
      #retrieve a value
      else
        self[method_name]
      end
    end

    #destroy the specified settings record
    def self.destroy(var_name)
      var_name = var_name.to_s
      obj = object(var_name)
      unless obj.nil?
        obj.destroy
        true
      else
        raise SettingNotFound, "Setting variable \"#{var_name}\" not found"
      end
    end

    #retrieve all settings as a hash (optionally starting with a given namespace)
    def self.get_all(starting_with = nil)
      vars = thing_scoped.select("var,value")
      if starting_with
        vars = vars.where("var LIKE '#{starting_with}%'")
      end

      result = {}
      vars.each do |record|
        result[record.var] = record.value
      end
      result.with_indifferent_access
    end
    
    def self.where(sql = nil)
      if sql
        vars = thing_scoped.where(sql)
      end
      vars
    end
    
    #get a setting value by [] notation
    def self.[](var_name)
      if var = object(var_name)
        var.value
      elsif @@defaults[var_name.to_s]
        @@defaults[var_name.to_s]
      else
        nil
      end
    end

    #set a setting value by [] notation
    def self.[]=(var_name, value)
      var_name = var_name.to_s

      record = object(var_name) || thing_scoped.new(:var => var_name)
      record.value = value
      record.save!

      value
    end

    def self.merge!(var_name, hash_value)
      raise ArgumentError unless hash_value.is_a?(Hash)

      old_value = self[var_name] || {}
      raise TypeError, "Existing value is not a hash, can't merge!" unless old_value.is_a?(Hash)

      new_value = old_value.merge(hash_value)
      self[var_name] = new_value if new_value != old_value

      new_value
    end

    def self.object(var_name)
      thing_scoped.where(:var => var_name.to_s).first
    end

    #get the value field, YAML decoded
    def value
      YAML::load(self[:value])
    end

    #set the value field, YAML encoded
    def value=(new_value)
      self[:value] = new_value.to_yaml
    end

    def self.thing_scoped
      unscoped.where("thing_type is NULL and thing_id is NULL")
    end

  end
end
