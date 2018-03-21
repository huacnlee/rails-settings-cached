require 'digest/md5'

module RailsSettings
  class Default < ::Hash
    class MissingKey < StandardError; end

    class << self
      def enabled?
        source_paths.try(:any?, lambda{ |path| File.exist?(path) })
      end

      def source(*paths)
        @source = Dir.glob(paths)
      end

      def source_paths
        @source || [Rails.root.join('config/app.yml')]
      end

      def [](key)
        # foo.bar.dar Nested fetch value
        return instance[key] if instance.key?(key)
        keys = key.to_s.split('.')
        instance.dig(*keys)
      end

      def instance
        return @instance if defined? @instance
        @instance = new
      end
    end

    def initialize
      content =
        self.class.source_paths.map do |path|
          open(path).read
        end.join("\n")
      hash = content.empty? ? {} : YAML.load(ERB.new(content).result).to_hash
      hash = hash[Rails.env] || {}
      replace hash
    end
  end
end
