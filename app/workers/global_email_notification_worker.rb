require 'mandrill'

class GlobalEmailNotificationWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def perform(notification_id)
    @notifcation = GlobalNotification.find(notification_id)
    title = @notifcation.title
    body = @notifcation.body
    image_url = @notifcation.image_file_name ? @notifcation.image.url : ''

    masters = User.current_employee.all

    masters.each do |m|
      if m.moc_email.present?
        p UserMailer.send_global_notification(title, body, image_url, m.moc_email).deliver
      end
    end
  end

end
