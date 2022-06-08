class Employee::Roles::AddRole::Add
  include Interactor

  def call
    context.fail!('couldn\'t set role') unless set_role

    context.response = context.master
  end

  private

  def set_role
    context.master.add_role(context.params[:role])
  end
end
