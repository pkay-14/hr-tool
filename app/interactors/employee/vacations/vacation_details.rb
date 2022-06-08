class Employee::Vacations::VacationDetails
  include Interactor::Organizer

  organize Employee::Shared::Master,
           Employee::Vacations::VacationDetails::Main
end
