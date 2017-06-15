module RailsSettings
  class ScopedSettings < Base

    def self.for_thing(object)
      Thread.current[:curren_object_for_rails_settings] = object
      self
    end

    def self.thing_scoped
      object = Thread.current[:curren_object_for_rails_settings]
      unscoped.where(thing_type: object.class.base_class.to_s, thing_id: object.id)
    end
  end
end