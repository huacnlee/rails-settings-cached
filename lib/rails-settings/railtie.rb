module RailsSettings
  class Railtie < Rails::Railtie
    
    initializer 'rails_settings.initialize', :after => :after_initialize do      
      Railtie.extend_active_record
    end

  end
  
  class Railtie
    def self.extend_active_record
      ActiveRecord::Base.class_eval do
        def self.has_settings
          class_eval do
            def settings
              RailsSettings::ScopedSettings.for_thing(self)
            end
            
            scope :with_settings, :joins => "JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND
                                                                     settings.thing_type = '#{self.base_class.name}')",
                                        :select => "DISTINCT #{self.table_name}.*" 
      
            scope :with_settings_for, lambda { |var| { :joins => "JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND
                                                                                          settings.thing_type = '#{self.base_class.name}') AND
                                                                                          settings.var = '#{var}'" } }
                                                                     
            scope :without_settings, :joins => "LEFT JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND
                                                                             settings.thing_type = '#{self.base_class.name}')",
                                           :conditions => 'settings.id IS NULL'
                                           
            scope :without_settings_for, lambda { |var| { :joins => "LEFT JOIN settings ON (settings.thing_id = #{self.table_name}.#{self.primary_key} AND
                                                                                                  settings.thing_type = '#{self.base_class.name}') AND
                                                                                                  settings.var = '#{var}'",
                                                                :conditions => 'settings.id IS NULL' } }
          end
        end
      end
    end
    
  end
end


