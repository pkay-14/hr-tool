class CreateJiraUsers < ActiveRecord::Migration
  def change
    create_table :jira_users do |t|
      t.string   :account_id
      t.string   :email
      t.timestamps
    end
  end
end
