require 'mandrill'

class SendMasterCareerHistoryNotificationWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false
  def perform(career_id)
    UserMailer.send_master_career_history_notification(career_id).deliver
  end
end
