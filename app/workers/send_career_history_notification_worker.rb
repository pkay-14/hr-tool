require 'mandrill'

class SendCareerHistoryNotificationWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false
  def perform(career_id, email)
    UserMailer.send_career_history_notification(career_id, email).deliver if email.present?
  end

end
