class Api::InternalEmailsController < Api::ApiController

  before_action :authorize_trusted!

  def send_internal_email
    InternalEmailWorker.perform_async(email_params)
    head :ok
  end

  private

  def email_params
    params.require(:email).permit(:from, :to, :subject, :body, cc: [])
  end

end
