class MasterModuleApi::Entities::Employees::Role < Grape::Entity
  expose :first_name
  expose :last_name
  expose :roles do |instance|
    instance.roles.pluck(:name)
  end
end
