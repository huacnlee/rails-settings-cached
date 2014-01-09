module RailsSettings
  module Configuration
    def self.serializer
      # The default serializer is YAML.
      @@serializer || YAML
    end

    def self.serializer= x
      raise ArgumentError.new("#{x} must respond to ::dump and ::load.") if !x.respond_to?(:dump) or !x.respond_to?(:load)
      @@serializer = x
    end
  end
end
