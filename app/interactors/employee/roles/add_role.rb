class Employee::Roles::AddRole
  include Interactor::Organizer

  organize Employee::Shared::Master,
           Employee::Roles::AddRole::Add
end
