class WelcomeController < ApplicationController
  def index
    render json: {
      host: Setting.host,
      admin_emails: Setting.admin_emails
    }
  end
end
