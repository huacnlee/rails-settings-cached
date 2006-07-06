class Settings < ActiveRecord::Base
  @@defaults      = (defined?(SettingsDefaults) ? SettingsDefaults::DEFAULTS : {}).with_indifferent_access
  
  class SettingNotFound < RuntimeError; end
  
  #get or set a variable with the variable as the called method
  def self.method_missing(method, *args)
    method_name = method.to_s
    
    if method_name.include? '='
      #set a value for a variable
      var_name = method_name.gsub('=', '')
      value = args.first
      self[var_name] = value
    else
      #retrieve a value
      self[method_name]
    end
  end
  
  #destroy the specified settings record
  def self.destroy(var_name)
    var_name = var_name.to_s
    if self[var_name]
      find(:first, :conditions => ['var = ?', var_name]).destroy
      true
    else
      raise SettingNotFound, "Setting variable \"#{var_name}\" not found"
    end
  end

  #retrieve all settings as a hash
  def self.all
    vars = find(:all, :select => 'var, value')
    
    result = {}
    vars.each do |record|
      result[record.var] = YAML::load(record.value)
    end
    result.with_indifferent_access
  end
  
  #reload all settings from the db
  def self.reload # :nodoc:
    self # deprecated, no longer needed since caching is not used.
  end
  
  #retrieve a setting value bar [] notation
  def self.[](var_name)
    #retrieve a setting
    var_name = var_name.to_s
    
    if var = find(:first, :conditions => ['var = ?', var_name])
      YAML::load(var.value)
    elsif @@defaults[var_name]
      @@defaults[var_name]
    else
      nil
    end
  end
  
  #set a setting value by [] notation
  def self.[]=(var_name, value)
    if self[var_name] != value
      var_name = var_name.to_s
      
      record = Settings.find(:first, :conditions => ['var = ?', var_name]) || Settings.new(:var => var_name)
      record.value = value.to_yaml
      record.save
    end
  end
end
