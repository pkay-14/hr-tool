require 'mandrill'

class SendVacationDisapprovalWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3
  def perform(vacation_id, manager_id)
    p  UserMailer.send_vacation_disapproval(vacation_id, manager_id).deliver
  end

end
