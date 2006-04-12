class Settings < ActiveRecord::Base
  @@defaults  = {}.with_indifferent_access
  @@cache     = {}.with_indifferent_access
  
  #returns the default values hash
  def self.default_values
    @@defaults
  end
  
  #sets the default values hash
  def self.default_values=(hash)
    @@defaults = hash.with_indifferent_access
  end
  
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
    return @@cache.delete(var_name.to_s) if delete_all(['var = ?', var_name.to_s]) #variable exists, destroy row and cache
    raise "Setting variable \"#{var_name}\" not found"
  end

  #retrieve all settings as a hash
  def self.all
    vars = find(:all, :select => 'var, value')
    
    result = {}
    vars.each do |record|
      result[record.var] = record.value
    end
    @@cache = result
    result.with_indifferent_access
  end
  
  #reload all settings form the db
  def self.reload
    self.all
    self
  end
  
  #retrieve a setting value bar [] notation
  def self.[](var_name)
    #retrieve a setting
    var_name = var_name.to_s
    
    return @@cache[var_name] if @@cache[var_name] #return cached value
    
    if var = find(:first, :conditions => ['var = ?', var_name])
      @@cache[var_name] = var.value
      var.value
    elsif @@defaults[var_name]
      @@defaults[var_name]
    else
      nil
    end
  end
  
  #set a setting value by [] notation
  def self.[]=(var_name, value)
    #set a value to a var name
    if self[var_name] != value
      var_name = var_name.to_s
      
      record = Settings.find(:first, :conditions => ['var = ?', var_name]) || Settings.new(:var => var_name)
      record.value = value
      record.save
      
      @@cache[var_name] = value
    end
  end
end