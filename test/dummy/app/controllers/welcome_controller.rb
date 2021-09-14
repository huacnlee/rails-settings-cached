class WelcomeController < ActionController::Base
  def index
    render json: {
      host: Setting.host,
      admin_emails: Setting.admin_emails
    }
  end
end
