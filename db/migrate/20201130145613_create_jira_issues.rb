class CreateJiraIssues < ActiveRecord::Migration
  def change
    create_table :jira_issues do |t|
      t.belongs_to :project, class_name: 'Jira::Project'
      t.string   :jira_id
      t.timestamps
    end
  end
end
