class RenameJiraIssueDescriptionFieldToSummary < ActiveRecord::Migration
  def change
    rename_column :jira_issues, :description, :summary
  end
end
