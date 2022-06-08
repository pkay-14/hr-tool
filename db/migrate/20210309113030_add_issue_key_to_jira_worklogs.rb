class AddIssueKeyToJiraWorklogs < ActiveRecord::Migration
  def change
    add_column :jira_worklogs, :issue_key, :string
  end
end
