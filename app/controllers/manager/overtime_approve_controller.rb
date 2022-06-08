class Manager:: OvertimeApproveController < ApplicationController

  before_action :require_login
  before_action :get_params
  before_action :for_pm_and_people_partner
  before_action :set_user
  before_action :overtime_approves, only: %i[index index_filters]
  before_action :set_approve, only: %i[edit approve dismiss revert_approve_status approve_comment_form dismiss_comment_form]
  layout 'admin'

  def index
    @overtime_approves
  end

  def index_filters
    render partial: 'overtime_list'
  end

  def edit
    head :no_content
    @approve.update_attributes(comment: overtime_approve_params[:pm_edited_comment])
  end

  def approve
    overtime = @approve.overtime
    @approve.update_attributes(is_approved: true, comment: overtime_approve_params[:comment], project_approved_on: overtime_approve_params[:project], approved_on_date: Date.today)
    if @approve.overtime.status.nil?
      @approve.overtime.approve_overtime
      Overtime.confirmed.where(:id.ne => overtime.id, date: overtime.date, employee_id: overtime.employee_id).destroy_all
    end
    redirect_to action: 'index'
  end

  def dismiss
    @approve.update_attributes(is_approved: false, comment: overtime_approve_params[:comment], approved_on_date: Date.today)
    @approve.check_dismissed
    redirect_to action: 'index'
  end

  def revert_approve_status
    @approve.update_attributes(is_approved: nil, comment: nil, project_approved_on: nil)
    @approve.overtime.revert_status if @approve.approver_of_overtime?
    redirect_to action: 'index', params: overtime_approve_params
  end

  def approve_comment_form
    @project_list = @approve.project_list(show_all = current_user.in?(User.pm_overtime_approvers) || current_user.is_people_partner?)
  end

  def dismiss_comment_form; end

  private

  def set_approve
    @approve = OvertimeApprove.find(overtime_approve_params[:id])
  end

  def overtime_approve_params
    params.permit(:id, :approved, :comment, :project, :status, :query, :to, :from, :pm_edited_comment)
  end

  def set_user
    @user = current_user
  end

  def get_params
    @overtime_approves_params = overtime_approve_params
  end

  def overtime_approves
    @overtime_approves = @user.overtime_approves.includes(:overtime, :manager)
    if overtime_approve_params[:status] == 'confirmed' || overtime_approve_params[:status] == 'dismissed'
      @overtime_approves = overtime_approve_params[:status] == 'confirmed' ? @overtime_approves.confirmed: @overtime_approves.dismissed
    elsif overtime_approve_params[:status] == ''
      @overtime_approves
    else
      @overtime_approves = @overtime_approves.where(is_approved: nil)
    end

    if overtime_approve_params[:query].present?
      search_overtimes = Overtime.full_text_search(overtime_approve_params[:query], match: :all)
      @overtime_approves = @overtime_approves.select{|approve| approve.overtime.in?(search_overtimes)}
    end

    if overtime_approve_params[:from] || overtime_approve_params[:to]
        @overtime_approves = Manager::OvertimeLibrary.new.filter_overtime_approves_date(@overtime_approves, overtime_approve_params[:from], overtime_approve_params[:to])
    end
    if @overtime_approves
      @overtime_approves = Manager::OvertimeLibrary.new.set_threshold_for_overtime_approves(@overtime_approves, 0.25)
      @overtime_approves = @overtime_approves.sort_by{ |approve| approve.overtime.date }.reverse!
      @overtime_approves = Kaminari.paginate_array(@overtime_approves).page(params[:page]).per(10)
    end
  end
end
