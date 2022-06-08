require 'mandrill'

class SendVacationApprovalWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3
  def perform(vacation_id)
    p  UserMailer.send_vacation_approval(vacation_id).deliver
  end

end
