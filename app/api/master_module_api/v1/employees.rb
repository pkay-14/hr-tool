class MasterModuleApi::V1::Employees < Grape::API
  namespace :employees do
    desc 'add master role'
    params do
      requires :master_id, type: String, allow_blank: false
      requires :role, type: String, allow_blank: false
    end
    get :add_role do
      respond_with Employee::Roles::AddRole,
                   MasterModuleApi::Entities::Employees::Role
    end

    desc 'delete master role'
    params do
      requires :master_id, type: String, allow_blank: false
      requires :role, type: String, allow_blank: false
    end
    get :remove_role do
      respond_with Employee::Roles::RemoveRole,
                   MasterModuleApi::Entities::Employees::Role
    end
  end
end
