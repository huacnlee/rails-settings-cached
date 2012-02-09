module RailsSettings
  module Extend
    extend ActiveSupport::Concern
    
    included do 
      scope :with_settings, :joins => "JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND
                                       settings.thing_type = '#{self.base_class.name}')",
                            :select => "DISTINCT #{self.table_name}.*" 

      scope :with_settings_for, lambda { |var| { :joins => "JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND
                                                             settings.thing_type = '#{self.base_class.name}') AND settings.var = '#{var}'" } }
                                                               
      scope :without_settings, :joins => "LEFT JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND
                                                                 settings.thing_type = '#{self.base_class.name}')",
                               :conditions => 'settings.id IS NULL'
                                     
      scope :without_settings_for, lambda { |var| { :joins => "LEFT JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND
                                                                                      settings.thing_type = '#{self.base_class.name}') AND
                                                                                      settings.var = '#{var}'",
                                                    :conditions => 'settings.id IS NULL' } }
    end
    
    def settings
      ScopedSettings.for_thing(self)
    end
  end
end


