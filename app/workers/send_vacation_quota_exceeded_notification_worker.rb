require 'mandrill'

class SendVacationQuotaExceededNotificationWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3
  def perform(master_id, email, quota_info = {})
    p  UserMailer.send_vacation_quota_exceeded_notification(master_id, email, quota_info).deliver
  end

end
