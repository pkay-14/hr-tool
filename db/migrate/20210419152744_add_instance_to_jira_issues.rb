class AddInstanceToJiraIssues < ActiveRecord::Migration
  def change
    add_column :jira_issues, :instance, :string
  end
end
