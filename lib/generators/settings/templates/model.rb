# RailsSettings Model
class <%= class_name %> < RailsSettings::CachedSettings
  source Rails.root.join("config/app.yml")
  namespace Rails.env
end
