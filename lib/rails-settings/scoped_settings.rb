module RailsSettings
  class ScopedSettings < CachedSettings
    def self.for_thing(object)
      @object = object
      self
    end

    def self.thing_scoped
      klass = @object.class
      primary_key = klass.primary_key
      id = @object.public_send(primary_key)
      unscoped.where(thing_type: klass.base_class.name, thing_id: id)
    end
  end
end
