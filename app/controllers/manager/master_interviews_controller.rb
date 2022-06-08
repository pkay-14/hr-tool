class Manager::MasterInterviewsController < ApplicationController

  before_action :require_login
  before_action :for_hr_pm_and_master_cabinet
  before_action :set_interviews, only: [ :index, :search ]

  layout "admin"

  def index
    @interview = MasterInterview.new
    @employee = User.current_employee_for_projects

    paginate_interviews
  end

  def index_filters
    @interview = MasterInterview.new
    @employee = User.current_employee_for_projects

    @interviews = MasterInterview.filter_by_params(params)

    paginate_interviews

    respond_to do |format|
      format.js
    end

  end

  def create
    @interview = MasterInterview.create!(interview_params)
    send_notification_emails
    redirect_to action: :index
  end

  def edit
    @interview = MasterInterview.find(params[:id])
  end

  def update
    @interview = MasterInterview.find(params[:id])
    send_notification_emails if params[:master_interview][:date] != @interview.date.to_s
    @interview.update_attributes(interview_params)
    redirect_to action: 'index'
  end

  def destroy
    @interview = MasterInterview.find(params[:id])
    @interview.destroy
    redirect_to action: 'index'
  end

  private


    def paginate_interviews
      @interviews = @interviews.page(params[:page]).per(15)
    end

    def send_notification_emails

      notification_time = @interview.date.to_datetime - 2.days

      interview_notification = Sidekiq::ScheduledSet.new.find_job(@interview.interview_notification)
      interview_notification_to_hr = Sidekiq::ScheduledSet.new.find_job(@interview.interview_notification_to_hr)
      interview_notification.try(:delete)
      interview_notification_to_hr.try(:delete)

      @interview.interview_notification = SendMasterInterviewNotificationWorker.perform_at(notification_time, @interview.id.to_s)
      @interview.interview_notification_to_hr = SendMasterInterviewNotificationToHrWorker.perform_at(notification_time, @interview.id.to_s)
      @interview.save
    end

    def set_interviews
      if params[:user_id].present?
        @interviews = MasterInterview.where(user_id: params[:user_id])
      else
        @interviews = MasterInterview.all
      end

      @interviews = @interviews.by_date.page(params[:page]).per(params[:per].present? ? params[:per] : 10)
    end

    def interview_params
      params.require(:master_interview).permit(:client, :project, :user_id,
        :date, :description, :feedback, :prepared, :successful, :passed
      )
    end

end
