# Hit readonly field before Rails initialize
Rails.application.config.to_prepare do
  Setting.readonly_item
  Setting.omniauth_google_options
  NoConnectionSetting.bar
end
