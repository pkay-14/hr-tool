require 'mandrill'

class InternalEmailWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def perform(email_params)
    MocInternalMailer.send_email(
      email_params['from'],
      email_params['to'],
      email_params['subject'],
      email_params['body'],
      email_params['cc']
    ).deliver
  end

end
