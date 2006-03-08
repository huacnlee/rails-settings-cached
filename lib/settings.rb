class Settings < ActiveRecord::Base
  @cache = {}

  def self.method_missing(method, *args)
    #get or set a variable with the variable as the called method
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

  def self.destroy(var_name)
    return @cache.delete(var_name.to_s) if delete_all(['var = ?', var_name.to_s]) #variable exists, destroy row and cache
    raise "Setting variable \"#{var_name}\" not found"
  end

  def self.all
    #retrieve all settings as a hash
    vars = find(:all, :select => 'var, value')
    
    result = {}
    vars.each do |record|
      result[record.var] = record.value
    end
    @cache = result
    result.with_indifferent_access
  end
  
  def self.reload
    #reload all settings form the db
    self.all
    self
  end

  def self.[](var_name)
    #retrieve a setting
    var_name = var_name.to_s
    
    return @cache[var_name] if @cache[var_name] #return cached value
    
    if var = find(:first, :conditions => ['var = ?', var_name])
      @cache[var_name] = var.value
      var.value
    else
      nil
    end
  end

  def self.[]=(var_name, value)
    #set a value to a var name
    var_name = var_name.to_s
    
    if (update_all(['value = ?',value], ['var = ?',var_name]) > 0) || create(:var => var_name, :value => value)
      @cache[var_name] = value 
    end
  end
end