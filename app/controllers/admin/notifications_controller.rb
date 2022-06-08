class Admin::NotificationsController < ApplicationController

  before_action :require_login
  before_action :for_hr

  layout "admin"

  def new
    @notification = GlobalNotification.new
    @categories = GlobalNotification::CATEGORIES
  end

  def create
    @notification = GlobalNotification.new(notification_params)
    if @notification.save
      # GlobalEmailNotificationWorker.perform_async(@notification.id.to_s)
      GlobalPushNotificationWorker.perform_async(@notification.id.to_s)
      redirect_to admin_employees_path, flash: {emails_sent: "Success"}
    else
      head :ok
    end
  end

  private

    def notification_params
      params.require(:global_notification).permit(:title, :body, :image, :category)
    end

end
