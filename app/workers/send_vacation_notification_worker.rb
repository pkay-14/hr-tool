require 'mandrill'

class SendVacationNotificationWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3
  def perform(vacation_id, email, show_link = true)
    p  UserMailer.send_vacation_notification(vacation_id, email, show_link).deliver
  end

end
