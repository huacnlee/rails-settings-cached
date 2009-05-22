class Settings < ActiveRecord::Base
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
    if self[var_name]
      object(var_name).destroy
      set_cache(var_name, nil)
      true
    else
      raise SettingNotFound, "Setting variable \"#{var_name}\" not found"
    end
  end

  #retrieve all settings as a hash (optionally starting with a given namespace)
  def self.all(starting_with=nil)
    options = starting_with ? { :conditions => "var LIKE '#{starting_with}%'"} : {}
    vars = object_scoped.find(:all, {:select => 'var, value'}.merge(options))
    
    result = {}
    vars.each do |record|
      result[record.var] = record.value
    end
    result.with_indifferent_access
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
    
    record = object(var_name) || object_scoped.new(:var => var_name)
    record.value = value
    record.save
    set_cache(var_name, record)
    
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
    result = get_cache(var_name)
    unless result
      result = object_scoped.find_by_var(var_name.to_s)
      set_cache(var_name, result)
    end
    result
  end
  
  def self.get_cache(var_name)
    Thread.current[:settings] ||= {}
    Thread.current[:settings]["#{var_name}#{object_type}#{object_id}"]
  end
  
  def self.set_cache(var_name, value)
    Thread.current[:settings] ||= {}
    Thread.current[:settings]["#{var_name}#{object_type}#{object_id}"] = value
  end
  
  #get the value field, YAML decoded
  def value
    YAML::load(self[:value])
  end
  
  #set the value field, YAML encoded
  def value=(new_value)
    self[:value] = new_value.to_yaml
  end
  
  def self.object_scoped
    Settings.scoped_by_object_type_and_object_id(object_type, object_id)
  end
  
  #Deprecated!
  def self.reload # :nodoc:
    self
  end
  
  def self.object_id
    nil
  end

  def self.object_type
    nil
  end
end

class ScopedSettings < Settings
  def self.for_object(object)
    @object = object
    self
  end
  
  def self.object_id
    @object.id
  end
  
  def self.object_type
    @object.class.base_class.to_s
  end
end