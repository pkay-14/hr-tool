class Manager::OvertimesController < ApplicationController

  before_action :require_login
  before_action :get_params
  before_action :for_hr_pm_and_master_cabinet
  before_action :overtimes, only: [:index, :index_filters, :export, :report]
  before_action :set_overtime, only: [:approve, :dismiss, :hr_revert_approve_status, :edit, :hr_approve_comment_form, :hr_dismiss_comment_form]
  before_action :set_modifier, only: [:approve, :dismiss]

  layout "admin"

  def index
    @employee = master_cabinet? ? User.where(id: current_user.id) : User.current_employee
  end

  def index_filters
    render :partial => "overtimes", locals: { overtimes: @overtimes }
  end

  def edit
    head :no_content
    @overtime.update_attributes(hr_approval_comment: @overtime_params[:hr_edited_comment], modifier: current_user)
  end

  def approve
    @overtime.approve_overtime(@overtime_params[:comment], @overtime_params[:project])
    Overtime.confirmed.where(:id.ne => @overtime.id, date: @overtime.date, employee_id: @overtime.employee_id).destroy_all
    redirect_to action: 'index'
  end

  def dismiss
    @overtime.dismiss_overtime(@overtime_params[:comment])
    redirect_to action: 'index'
  end

  def hr_approve_comment_form
    @project_list = @overtime.project_list
  end

  def hr_dismiss_comment_form; end

  def hr_revert_approve_status
    @overtime.revert_status_for_hr unless @overtime.confirmed_by_approver?
    redirect_to action: 'index', params: @overtime_params
  end

  def report; end

  def export
    today = Date.today
    if @overtime_params[:from].blank? &&  @overtime_params[:to].blank?
      from = (today - 61).beginning_of_month.strftime('%d.%m.%Y')
      to = today.end_of_month.strftime('%d.%m.%Y')
      period = "#{from}-#{to}"
    elsif @overtime_params[:from].present? &&  @overtime_params[:to].present?
      period = "#{@overtime_params[:from].to_date.strftime('%d.%m.%Y')}-#{@overtime_params[:to].to_date.strftime('%d.%m.%Y')}"
    else
      period = @overtime_params[:from].present? ? "from: #{@overtime_params[:from].to_date.strftime('%d.%m.%Y')}" :
                 "to: #{@overtime_params[:to].to_date.strftime('%d.%m.%Y')}"
    end
    sheet_name = "Overtime Report(#{period})"
    if Rails.env.eql?('production')
      user_email = current_user.moc_email.blank? ? current_user.email : current_user.moc_email
    else
      user_email = "testtost2018@gmail.com"
    end
    link = Manager::GoogleSheet.new(sheet_name, @overtime_params[:from], @overtime_params[:to]).get_sheet(user_email)
    ExportOvertimesWorker.perform_at(Time.now, @overtimes.map{ |ov| ov.id.to_s }, sheet_name, @overtime_params[:from], @overtime_params[:to])
    sleep 10.seconds
    respond_to do |format|
      format.json{render json: {url: link}}
      format.html do
        redirect_to link.to_s
      end
    end
  end

  private
  def set_overtime
    @overtime = Overtime.find(@overtime_params[:id])
  end

  def set_modifier
    @overtime.update(modifier: current_user)
  end

  def overtimes
    pending_modified = Overtime.pending_modified.pluck(:id)
    if @overtime_params[:status] == 'confirmed' || @overtime_params[:status] == 'dismissed'
      @overtimes = Overtime.where(:id.nin => pending_modified, status: @overtime_params[:status])
    elsif @overtime_params[:status] == 'pending'
      @overtimes = Overtime.where(:id.nin => pending_modified, status: nil)
    else
      @overtimes = Overtime.all.nin(id: pending_modified)
    end

    if @overtimes

      @overtimes = Manager::OvertimeLibrary.new.set_threshold_for_overtimes(@overtimes, 0.25)
    end

    if master_cabinet?
      @overtimes = @overtimes.confirmed.where(employee_id: current_user.id)
    else
      @overtimes = @overtimes.full_text_search(@overtime_params[:query], match: :all) if @overtime_params[:query].present?
    end
    export = @overtime_params[:action].eql?('export')
    if export
      @overtimes = Manager::OvertimeLibrary.new.filter_overtimes_for_export(@overtimes, @overtime_params[:from], @overtime_params[:to], @overtime_params[:status])
    else
      @overtimes = Manager::OvertimeLibrary.new.filter_overtime_date(@overtimes, @overtime_params[:from], @overtime_params[:to])
    end
    @overtimes = Overtime.where(:id.in => @overtimes.map{|ov| ov.id})
    @overtimes = @overtimes.by_date.page(params[:page]).per(10) unless export
    @overtimes.includes(:employee, :approves) if @overtimes.present?
  end

  def overtime_params
     params.permit(:id, :employee_id, :from_date, :to_date, :status, :master, :user, :master_cabinet, :only_role, :query, :per_page, :page,
                    :from, :to, :project, :hr_edited_comment, :comment,:action)

  end

  def get_params
    @overtime_params = overtime_params
  end

  def set_master_cabinet_param
    @master_cabinet_param = master_cabinet? ? '?master=true' : ''
  end
  def get_host_url
    request.url.split('/').first(5).join('/')
  end
end
