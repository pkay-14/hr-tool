class Employee::VacationApproves::ConfirmVacation::Confirm
  include Interactor

  def call
    context.fail!(error_code: 422, error: 'couldn\'t approve vacation') unless confirm_vacation
    context.response = { status: 200 }
    context.redirect_url = "#{context.request.base_url}/manager/vacation_approve"
  end

  private

  def confirm_vacation
    approve = VacationApprove.find(context.params[:id])
    vacation = approve.vacation
    approve.update_attributes(is_approved: true)
    if approve.manager.eql?(vacation.people_partner)
      vacation.approve!
      SendVacationApprovalWorker.perform_async(vacation.id.to_s) if vacation.from >= Date.today
      vacation.send_notification_emails if vacation.from >= Date.today
    else
      vacation.check_is_approved
    end
    approve.is_approved?
  end
end
