class Manager::CalendarController < ApplicationController
  include Manager::CalendarHelper

  layout "admin"

  before_action :require_login
  before_action :for_hr_pm_lead_and_master_cabinet
  before_action :set_dates, only: [:index, :index_filters, :batch, :user_load_detailed]
  before_action :set_users, only: [:index_filters, :batch, :user_load_detailed]
  before_action :set_batch_token, only: [:index_filters]
  before_action :update_default_pagination_per_page, only: [:index_filters]
  before_action :set_teammates, only: [:batch, :user_load_detailed]
  before_action :set_jira_data, only: [:batch, :user_load_detailed]

  def index
    gon.init_load_calendar = true

    respond_to do |format|
      format.js
      format.html
    end
  end

  def index_filters
    @users = paginate_users(@users)
    @options = {}
    @options['tech'] = params[:tech]
    @options['load_status'] = params[:load_status]
    @options['project_category'] = params[:project_category]
    @options['company_division'] = params[:company_division]
    @options['community'] = params[:community]
    @options['position'] = params[:position]
    @options['sort_name'] = params[:sort_name]
    @options['sort_total'] = params[:sort_total]
    @options['search_query'] = params[:search_query]
    @options['team'] = params[:team]
    @options['teammates'] = to_boolean(params[:teammates])
    per_page = params[:per_page] ? params[:per_page].to_i : default_per_page
    page = params[:page] ? params[:page].to_i : 1
    previous_batches_quantity = (per_page*(page-1)/10.to_f).ceil
    @batches_quantity = previous_batches_quantity + (@users.count/10.to_f).ceil
    @batch_number = previous_batches_quantity + 1

    @users_batch = []
    @jira_data = []

    respond_to do |format|
      format.js
    end
  end

  def batch
    @users = sort_by_total if params[:sort_total].present?
    @batch_token = params[:batch_token]
    if master_cabinet? && !@teammates
      @users_batch = Kaminari.paginate_array(@users.to_a).page(1).per(10)
    else
      @users_batch = paginate_users(@users.is_a?(Array) ? @users : @users.includes(:loads, :vacations))
    end

    respond_to do |format|
      format.js
    end
  end

  def user_load_detailed
    respond_to do |format|
      format.js
    end
  end

  private

  def set_users
    return @users = User.by_teammate(current_user, params[:sort_name]) if to_boolean(params[:teammates])
    return @users = current_user if master_cabinet?
    return @users = User.find(params[:user_id]) if params[:user_id].present?

    @users = User.filter_by_params(params.merge({
                                                  'current_user_id' => current_user.id.to_s,
                                                  'masters_for_load_calendar' => true,
                                                  'date' => @date
                                                }))
  end

  def paginate_users(users)
    Kaminari.paginate_array(users.to_a).page(params[:page]).per(params[:per_page] ? params[:per_page] : default_per_page)
  end

  def set_teammates
    @teammates = to_boolean(params[:teammates])
  end

  def set_dates
    @date = params[:date].present? && valid_date?(params[:date].to_s) ? Date.strptime(params[:date], '%Y-%m-%d') : Date.today
    @from_date = @date.beginning_of_month
    @to_date = @date.end_of_month
    @holidays = Holiday.where(date: @from_date..@to_date)
  end

  def valid_date?(date_string)
    date_string.try(:to_date)
    true
  rescue ArgumentError
    false
  end

  def set_jira_data
    return @jira_data = {} if master_cabinet? && @teammates
    jira_account_ids = case @users
                   when User
                     @users.jira_account_id
                   when Array
                     @users&.map {|user| user.jira_account_id}
                   else
                     @users&.pluck(:jira_account_id)
                 end
    @jira_users = Jira::User.where(account_id: jira_account_ids)
    jira_projects = Jira::Project.all
    @worklogs = Jira::Worklog.where(user: @jira_users).where('date >= ? AND date <= ?', @from_date, @to_date)
    month_time = @worklogs.group(['user_id']).group_by_month(:date, range: @from_date..@to_date).sum(:time_spent_seconds)

    @jira_data = {
      'jira_users' => @jira_users,
      'jira_projects' => jira_projects,
      'month_time' => month_time,
    }
    if master_cabinet? || params[:action] == 'user_load_detailed'
      users_projects = @worklogs.group(:user_id, :project_id).count
      users_projects = users_projects.map {|el| {'user_id' => el[0][0], 'project_id' => el[0][1], 'mapped' => false}}
      project_day_time = @worklogs.group(['user_id', 'project_id']).group_by_day(:date, range: @from_date..@to_date).sum(:time_spent_seconds)
      project_month_time = @worklogs.group(['user_id', 'project_id']).group_by_month(:date, range: @from_date..@to_date).sum(:time_spent_seconds)
      day_time = @worklogs.group(['user_id']).group_by_day(:date, range: @from_date..@to_date).sum(:time_spent_seconds)

      @jira_data['project_day_time'] = project_day_time
      @jira_data['project_month_time'] = project_month_time
      @jira_data['users_projects'] = users_projects
      @jira_data['day_time'] = day_time
    end
  end

  def sort_by_total
    users = @users.sort_by do |user|
      jira_user_id = @jira_data['jira_users']&.find_by(account_id: user.jira_account_id)&.id if @jira_data.present?
      user_month_time(@jira_data, jira_user_id, @date).to_f
    end
    case params[:sort_total]
    when 'ascending'
      @users = users
    when 'descending'
      @users = users.reverse
    else
      @users
    end
  end

  def default_per_page
    current_user.pagination_per_page || 30
  end

  def update_default_pagination_per_page
    if params[:per_page].present? && params[:per_page].to_i != current_user.pagination_per_page && params[:page].nil?
      current_user.update({pagination_per_page: params[:per_page]})
    end
  end

  def set_batch_token
    @batch_token = SecureRandom.hex(10)
  end

end
