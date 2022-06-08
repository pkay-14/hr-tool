require 'mandrill'

class SendTimeTrackingNotificationWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false
  def perform(email)
    p  UserMailer.send_time_tracking_notification(email).deliver
  end

end
