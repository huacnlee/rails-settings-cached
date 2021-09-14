module RailsSettings
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      RailsSettings::RequestCache.enable!
      result = @app.call(env)
      RailsSettings::RequestCache.disable!
      result
    end
  end
end
