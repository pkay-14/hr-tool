class RenameStatusToLabelInJiraIssues < ActiveRecord::Migration
  def change
    rename_column :jira_issues, :status, :label
  end
end
