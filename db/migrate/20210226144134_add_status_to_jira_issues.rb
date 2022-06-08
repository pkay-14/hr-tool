class AddStatusToJiraIssues < ActiveRecord::Migration
  def change
    add_column :jira_issues, :status, :string
  end
end
