module RailsSettings
  class ScopedSettings < Settings
    def self.for_thing(object)
      @object = object
      self
    end
    
    def self.thing_scoped
      Settings.scoped_by_thing_type_and_thing_id(@object.class.base_class.to_s, @object.id)
    end
 
  end
end