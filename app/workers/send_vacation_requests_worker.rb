require 'mandrill'

class SendVacationRequestsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3
  def perform(approve_id)
    p  UserMailer.send_vacation_requests(approve_id).deliver
  end

end
