module RailsSettings
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      RailsSettings::RequestCache.enable!
      @app.call(env)
      RailsSettings::RequestCache.disable!
    end
  end
end
