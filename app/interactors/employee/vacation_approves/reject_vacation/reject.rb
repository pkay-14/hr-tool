class Employee::VacationApproves::RejectVacation::Reject
  include Interactor

  def call
    context.fail!(error_code: 422, error: 'couldn\'t reject vacation') unless reject_vacation
    context.response = { status: 200 }
  end

  private

  def reject_vacation
    approve = VacationApprove.find(context.params[:id])
    approve.update_attributes(is_approved: false, comment: context.params[:comment])
    approve.vacation.reject!
    SendVacationDisapprovalWorker.perform_async(approve.vacation.id.to_s, current_user.id.to_s) if approve.vacation.from >= Date.today
  end
end
