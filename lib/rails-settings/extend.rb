module RailsSettings
  module Extend
    extend ActiveSupport::Concern
    
    included do 
      scope :with_settings, -> {
        joins("JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND
                                               settings.thing_type = '#{self.base_class.name}')")
        .select("DISTINCT #{self.table_name}.*")
      } 
                             

      scope :with_settings_for, ->(var) {
        joins("JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND
              settings.thing_type = '#{self.base_class.name}') AND settings.var = '#{var}'") 
      }
                                                               
      scope :without_settings, -> {
        joins("LEFT JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND settings.thing_type = '#{self.base_class.name}')")
        .where("settings.id IS NULL")    
      } 
                                     
      scope :without_settings_for, ->(var) {
        where('settings.id IS NULL')
        .joins("LEFT JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND
               settings.thing_type = '#{self.base_class.name}') AND settings.var = '#{var}'")
      }
                                                                                    
    end
    
    def settings
      ScopedSettings.for_thing(self)
    end
  end
end


