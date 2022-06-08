class Employee::Vacations::CreateVacation
  include Interactor::Organizer

  organize Employee::Shared::Master,
           Employee::Vacations::CreateVacation::Create
end
