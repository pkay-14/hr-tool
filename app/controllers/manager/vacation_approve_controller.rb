class Manager::VacationApproveController < ApplicationController

  before_action :require_login
  before_action :for_hr_pm_designer_interviewer_ba_lead_head_of_marketing_and_infrastructure_leader
  before_action :set_user

  layout "admin"

  def index
    @vacation_approves = current_user.vacation_approves.includes(:vacation).select { |va| va.is_approved.nil? && va.vacation.status.nil? }
  end

  def approve
    @approve = VacationApprove.find(params[:id])
    @approve.update_attributes(is_approved: true)
    @approve.vacation.check_is_approved(second_level = @approve.second_level_approver)
    redirect_to action: 'index'
  end

  def reject
    @approve = VacationApprove.find(params[:id])
    @approve.update_attributes(is_approved: false, comment: params[:comment])
    @approve.vacation.reject!
    SendVacationDisapprovalWorker.perform_async(@approve.vacation.id.to_s, current_user.id.to_s) if @approve.vacation.from >= Date.today
    redirect_to action: 'index'
  end

  def comment_form
    @approve = VacationApprove.find(params[:id])
  end

  private

  def vacation_params
    params.permit(:id, :approved, :comment)
  end

  def set_user
    @user = current_user
  end

end
