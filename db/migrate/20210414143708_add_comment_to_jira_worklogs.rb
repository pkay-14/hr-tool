class AddCommentToJiraWorklogs < ActiveRecord::Migration
  def change
    add_column :jira_worklogs, :comment, :string
  end
end
