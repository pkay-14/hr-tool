require 'mandrill'

class SendVacationRequestNotificationWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3
  def perform(vacation_id, email)
    p UserMailer.send_vacation_request_notification(vacation_id, email).deliver
  end

end
