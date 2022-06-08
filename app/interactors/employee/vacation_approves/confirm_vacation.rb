class Employee::VacationApproves::ConfirmVacation
  include Interactor::Organizer

  organize Employee::VacationApproves::ConfirmVacation::Confirm
end
