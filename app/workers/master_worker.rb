class MasterWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def perform(user_id)
    user = User.find(user_id)
    user.set_accounting_data
    user.set_jira_account_id
  end
end