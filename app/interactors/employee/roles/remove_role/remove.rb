class Employee::Roles::RemoveRole::Remove
  include Interactor

  def call
    context.fail!('couldn\'t remove role') unless remove_role

    context.response = context.master
  end

  private

  def remove_role
    context.master.remove_role(context.params[:role])
  end
end
