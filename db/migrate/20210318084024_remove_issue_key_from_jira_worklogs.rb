class RemoveIssueKeyFromJiraWorklogs < ActiveRecord::Migration
  def change
    remove_column :jira_worklogs, :issue_key
  end
end
