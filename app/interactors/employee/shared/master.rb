class Employee::Shared::Master
  include Interactor

  def call
    context.fail!(error: 'cannot find master') unless master
  end

  private

  def master
    context.master = User.find(context.params[:master_id])
  end
end
