class AddTimeZoneToJiraUsers < ActiveRecord::Migration
  def change
    add_column :jira_users, :time_zone, :string
  end
end
