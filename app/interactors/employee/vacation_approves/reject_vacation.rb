class Employee::VacationApproves::RejectVacation
  include Interactor::Organizer

  organize Employee::VacationApproves::RejectVacation::Reject
end
