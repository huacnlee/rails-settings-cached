module RailsAppSettings
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      RailsAppSettings::RequestCache.enable!
      result = @app.call(env)
      RailsAppSettings::RequestCache.disable!
      result
    end
  end
end
