class Manager::VacationsController < ApplicationController

  before_action :require_login
  before_action :for_hr_and_pm, except: [:index, :index_filters, :create, :destroy, :vacation_days]
  before_action :for_hr_pm_lead_designer_and_master_cabinet, only: [:index]
  before_action :for_hr_pm_lead_and_master_cabinet, only: [:index_filters]
  before_action :for_hr_pm_and_master_cabinet, only: [:create, :destroy, :vacation_days]
  before_action :vacations, only: [:index, :index_filters, :export]
  before_action :check_date, only: :create
  before_action :set_user, only: [:create, :vacation_days]
  before_action :set_master_cabinet_param, only: [:index, :create, :destroy]
  before_action :set_vacation, only: [:approve, :reject, :destroy]
  before_action :set_modifier, only: [:approve, :reject, :destroy]

  layout "admin"

  def index
    @employee = master_cabinet? ? User.where(id: current_user.id) : User.current_employee
    @current_year = Date.today.year
    @past_year = @current_year - 1
    define_vacation
    @params = params
  end

  def index_filters
  end

  # def create
    # vacations_params = [vacation_params]
    # if quota_exceeded?
    #   if vacation_params[:to].to_date.year > Date.today.year
    #     quota = vacation_params[:category] == 'vacation' ? @user.vacation_days_current_year : @user.sick_days
    #   else
    #     quota = vacation_params[:category] == 'vacation' ? @user.vacation_days : @user.sick_days
    #   end
    #   if quota > 0
    #     if quota.eql?(0.5) && working_days > quota
    #       vacations_params[0][:category] = 'days-off'
    #     else
    #       from = vacation_params[:from].to_date
    #       to = paid_vacation_end(from, quota)
    #       vacations_params[0][:to] = to.strftime('%d.%m.%Y')
    #       vacations_params << vacation_params
    #       vacations_params[1][:from] = (to + 1).strftime('%d.%m.%Y')
    #       vacations_params[1][:category] = 'days-off'
    #     end
    #   else
    #     vacations_params[0][:category] = 'days-off'
    #   end
    # end
    #
    # vacations_params.each do |vacation_params|
    #   @vacation = Vacation.create!(vacation_params.merge(modifier: current_user))
    #   if @vacation.category == 'sick'
    #     @vacation.approve!
    #     @vacation.send_notification_emails
    #   else
    #     send_approve_emails
    #     @vacation.send_request_notification_emails if @user.country.name == 'USA'
    #   end
    #   @vacation.process_days
    # end
    #
    # if quota_exceeded? && vacation_params[:category] == 'sick'
    #   quota_info = {total: working_days, quota: quota, excess: working_days - quota}
    #   SendVacationQuotaExceededNotificationWorker.perform_async(@user.id.to_s,'hr@masterofcode.com', quota_info)
    # end
    #
    # redirect_to "#{manager_vacations_path}#{@master_cabinet_param}"
  # end

  # def edit
  #   @vacation = Vacation.find(params[:id])
  # end

  def destroy
    @vacation.destroy
    redirect_to "#{manager_vacations_path}#{@master_cabinet_param}"
  end

  def approve
    @vacation.approve!
    SendVacationApprovalWorker.perform_async(@vacation.id.to_s) if @vacation.from >= Date.today
    @vacation.send_notification_emails
    redirect_to action: 'index'
  end

  def reject
    @vacation.reject!
    SendVacationDisapprovalWorker.perform_async(@vacation.id.to_s, current_user.id.to_s) if @vacation.from >= Date.today
    redirect_to action: 'index'
  end

  def vacation_days
    category = vacation_params[:category]
    from = vacation_params[:from]
    to = vacation_params[:to]
    half_day = vacation_params[:half_day]

    data = {}
    data[:working_days] = working_days
    if category == 'vacation'
      if to == nil
        data[:past_year_days] = [@user.vacation_days_past_year - working_days, 0].max
        current_year_vacation_part = [working_days - @user.vacation_days_past_year, 0].max
        data[:current_year_days] = @user.remaining_vacation_days_current_year - current_year_vacation_part
        data[:next_year_days] = 0
      elsif to.to_date.year > Date.today.year
        data[:past_year_days] = @user.vacation_days_past_year
        data[:current_year_days] = [@user.remaining_vacation_days_current_year - working_days, 0].max
        next_year_vacation_part = [working_days - @user.remaining_vacation_days_current_year, 0].max
        data[:next_year_days] = @user.next_year_vacation_days_remaining - next_year_vacation_part
      else
        data[:past_year_days] = [@user.vacation_days_past_year - working_days, 0].max
        current_year_vacation_part = [working_days - @user.vacation_days_past_year, 0].max
        data[:current_year_days] = @user.remaining_vacation_days_current_year - current_year_vacation_part
        data[:next_year_days] = 0
      end
    elsif category == 'sick'
      data[:current_year_days] = from&.to_date.present? && from.to_date.year > Date.today.year ? 0.0 - working_days : @user.sick_days_remaining - working_days
    elsif category == 'days-off'
      data[:past_year_days] = [@user.vacation_days_past_year - working_days, 0].max
      current_year_vacation_part = [working_days - @user.vacation_days_past_year, 0].max
      data[:current_year_days] = @user.remaining_vacation_days_current_year - current_year_vacation_part
    end
    data[:hr_manager] = current_user.is_hr_manager?
    data[:future_employee?] = @user.future_employee?
    data[:overlaps] = Vacation.overlaps?(@user, from, to, to_boolean(half_day))

    respond_to do |format|
      format.json {render json: data}
    end
  end

  def export
    content = Manager::VacationLibrary.new.export_to_csv(@vacations.limit(1000).offset(0))
    if content.present?
      start_date = params[:filter_start_date].present? ? params[:filter_start_date] : Date.today.beginning_of_year
      end_date = params[:filter_end_date].present? ? params[:filter_end_date] : Date.today.end_of_year
      send_data content, filename: "Vacations Report from #{start_date} to #{end_date}.csv"
    end
  end

  def ajax_export
    respond_to do |format|
      format.json {render json: {export_to_csv_url: "#{export_manager_vacations_path(params: export_params)}"}}
    end
  end

  private
  def set_vacation
    @vacation = Vacation.find(params[:id])
  end

  def set_modifier
    @vacation.update(modifier: current_user)
  end

  def vacation_params
    params.require(:vacation).permit(:id, :from, :to, :employee_id, :category, :half_day, :notes)
  end

  def export_params
    params.permit(:status, :query, :category, :project, :filter_start_date, :filter_end_date)
  end

  def working_days
    working_days = 0.0
    return working_days unless vacation_params[:from].present? || vacation_params[:to].present?

    (vacation_params[:from].to_date..vacation_params[:to].to_date).each do |day|
      unless (day.saturday? || day.sunday?) || Holiday.where(date: day, country: @user.country).any?
        working_days += 1.0;
      end
    end
    to_boolean(vacation_params[:half_day]) ? working_days/2 : working_days
  end

  # def quota_exceeded?
    # if vacation_params[:to].to_date.year > Date.today.year
    #   (vacation_params[:category] == 'vacation' && working_days > @user.vacation_days_current_year) ||
    #     (vacation_params[:category] == 'sick' && working_days > @user.sick_days)
    #
    # else
    #   (vacation_params[:category] == 'vacation' && working_days > @user.vacation_days) ||
    #     (vacation_params[:category] == 'sick' && working_days > @user.sick_days)
    # end

  # end

  # def paid_vacation_end(from, working_days)
  #   working_days -= 1 if Calendar.working_day?(from, @user.country)
  #   to = from
  #   working_days.to_i.times do
  #     begin
  #       to += 1
  #     end until Calendar.working_day?(to, @user.country)
  #   end
  #   to
  # end

  def vacations
    if params[:status] == 'approved' || params[:status] == 'rejected'
      @vacations = Vacation.where(status: params[:status])
    elsif params[:status] == 'pending'
      @vacations = Vacation.where(status: nil)
    else
      @vacations = Vacation.all
    end

    if params[:project].present?
      loads = Project.find_by(name: params[:project]).loads
      Load.filter_by_date!(loads, params[:filter_start_date]&.to_date) if params[:filter_start_date].present?
      Load.filter_by_date!(loads, params[:filter_end_date]&.to_date) if params[:filter_end_date].present?
      Load.filter_by_date!(loads, Date.today) if params[:filter_start_date].blank? && params[:filter_end_date].blank?

      employee_load_dates = loads.map { |load| Hash[load.employee.id.to_s => [load.get_from_date..load.get_to_date]] }
      employee_load_dates = combine(employee_load_dates)
      vacations = []

      User.in(id: loads.pluck(:employee)).includes(:vacations).map do |employee|
        employee_load_dates.fetch(employee.id.to_s).each do |range|
          vacations << employee.vacations.in(from: range).pluck(:id)
        end
      end
      @vacations = @vacations.in(id: vacations.flatten.uniq)
    end

    if master_cabinet?
      @vacations = @vacations.where(employee_id: current_user.id)
    else
      @vacations = @vacations.full_text_search(params[:query], match: :all) if params[:query].present?
    end

    @vacations = @vacations.where(category: params[:category]) if params[:category].present?

    if params[:filter_start_date].present? || params[:filter_end_date].present?
      @vacations = Manager::VacationLibrary.new.filter_vacation_date(@vacations, params[:filter_start_date], params[:filter_end_date])
    end

    @vacations = @vacations.by_date.page(params[:page]).per(params[:per_page] ? params[:per_page] : 10)
    @vacations.includes(:employee, :approves)
  end

  def combine(array)
    array.each_with_object({}) do |item, hash|
      key, value = item.shift
      ((hash[key] ||= []) << value).flatten!
    end
  end

  def define_vacation
    @vacation = Vacation.new
  end

  # def send_approve_emails
    # @vacation.approvers.each do |approver|
    #   vacation_approve = VacationApprove.create!(vacation_id: @vacation._id, manager_id: approver._id)
    #   SendVacationRequestsWorker.perform_async(vacation_approve.id.to_s) if @vacation.from >= Date.today
    # end
  # end

  def check_date
    unless vacation_params[:from].present? && vacation_params[:to].present?
      redirect_to :back
    end
  end

  def set_user
    @user = User.find(vacation_params[:employee_id])
  end

  def set_master_cabinet_param
    @master_cabinet_param = master_cabinet? ? '?master=true' : ''
  end

end
