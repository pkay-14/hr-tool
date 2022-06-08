class Employee::Roles::RemoveRole
  include Interactor::Organizer

  organize Employee::Shared::Master,
           Employee::Roles::RemoveRole::Remove
end
