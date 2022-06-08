class AddJiraIssueToJiraWorklogs < ActiveRecord::Migration
  def change
    add_column :jira_worklogs, :issue_id, :integer, :null => true
  end
end
