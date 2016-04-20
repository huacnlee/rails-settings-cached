require 'settingslogic'

module RailsSettings
  class Default < ::Hash
    class MissingKey < StandardError; end

    class << self
      def enabled?
        @source && File.exists?(@source)
      end

      def source(value = nil)
        @source ||= value
      end

      def [](key)
        # foo.bar.dar Nested fetch value
        keys = key.to_s.split('.')
        val = instance
        keys.each do |k|
          val = val.fetch(k.to_s, nil)
          break if val.nil?
        end
        val
      end

      def instance
        return @instance if defined? @instance
        @instance = new(@source)
        @instance
      end
    end

    def initialize(source)
      content = open(source).read
      hash = content.empty? ? {} : YAML.load(ERB.new(content).result).to_hash
      hash = hash[Rails.env] || {}
      self.replace hash
    end
  end
end
