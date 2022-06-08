class AddMoreFieldsToJiraIssues < ActiveRecord::Migration
  def change
    add_column :jira_issues, :key, :string
    add_column :jira_issues, :description, :string
    add_column :jira_issues, :api_url, :string
  end
end
