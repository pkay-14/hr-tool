require 'mandrill'

class SendProjectLoadNotificationWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false
  def perform(model, id)
    p  UserMailer.send_project_load_notification(model, id).deliver
  end

end
