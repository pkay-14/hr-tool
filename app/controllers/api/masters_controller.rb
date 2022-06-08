class Api::MastersController < Api::ApiController

  include Shared

  before_action -> { authorize_trusted!('common') }, except: [:check_reminder_need, :list, :actual_loads, :charges]
  before_action -> { authorize_trusted! }, only: [:list, :actual_loads, :charges]
  before_action :set_dates, only: [:working_days_number, :time_tracking, :list, :actual_loads, :charges]
  before_action :set_master, only: [:info, :projects, :time_tracking]
  before_action :check_jira_account_id, only: [:time_tracking]

  def index
    @masters = User.current_employee_for_projects

    render json: @masters.to_json(methods: [:id.to_s, :avatar_url, :full_name, :birthday.to_s],
                                  only: [:first_name, :last_name, :moc_email, :tel_number])
  end

  # type = 'manager' or 'master'
  def check_reminder_need
    render json: { value: true }.to_json
  end

  def list
    masters = User.actual_employee_at_date(@to) + User.recently_left_employee(Date.new(@from.to_date.year, @from.to_date.month)-1.month).where(:left_at.lt => @to)
    render json: masters.to_json(methods: [:full_name, :name_of_country, :name_of_office], only: [:is_support])
  end

  def actual_loads
    render json: Utils::JiraLibrary::JiraManager.project_month_time(@from, @to).to_json
  end

  def charges
    render json: Acc::GeneralReport.new(@from.to_date.year, @from.to_date.month).to_kpi_json
  end

  def info
    render json: {office: @master&.office&.name, time_tracking: @master&.send_time_tracking_reminders}
  end

  def projects
    lp_master = false
    projects = []
    @master&.current_projects&.each do |project|
      lp_master = project.category == 'LivePerson' unless lp_master
      projects << project.name
    end

    render json: {lp_master: lp_master, projects: projects}
  end

  def time_tracking
    jira_user = Jira::User.find_by(account_id: @master.jira_account_id)

    tracked_time = []
    worklogs = jira_user.worklogs.where('date >= ? AND date <= ?', @from, @to).group_by_day(:date).sum(:time_spent_seconds)
    worklogs.each { |k, v| tracked_time << {date: k, planned: 0, tracked: to_hours(v)}}

    planned_time = @master.planned_time(@from, @to)
    planned_time.each { |h| h[:tracked] = 0}
    time_tracking_info = group_data(planned_time + tracked_time, [:date], [:planned, :tracked])

    render json: {worklogs: time_tracking_info}.to_json
  end

  def working_days_number
    count = 0
    (@from.to_date..@to.to_date).each{|d| count+=1 if (1..5).include?(d.wday) && !Holiday.is_holiday?(d)}
    render json: {working_days_number: count}.to_json
  end

  private

  def set_dates
    begin
      @from = masters_params[:from].to_date
      @to = masters_params[:to].to_date
    rescue
      render json: {error: 'date range is invalid!'}.to_json
    end
  end

  def set_master
    @master = User.where(moc_email: masters_params[:email]).first

    render json: {error: 'master is not found!'}.to_json unless @master.present?
  end

  def check_jira_account_id
    render json: {error: 'no jira_account_id for the master!'}.to_json unless @master&.jira_account_id.present?
  end

  def masters_params
    params.permit(:from, :to, :email)
  end

  def to_hours(seconds)
    hours = (seconds.to_f / 3600).round(2)
    hours = hours.to_i if hours.to_f == hours.to_i
    hours
  end

end
