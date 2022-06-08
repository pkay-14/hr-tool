class CreateJiraWorklogs < ActiveRecord::Migration
  def change
    create_table :jira_worklogs do |t|
      t.string   :instance
      t.belongs_to :user, class_name: 'Jira::User'
      t.belongs_to :project, class_name: 'Jira::Project'
      t.string   :jira_id
      t.date     :date
      t.integer  :time_spent_seconds
      t.timestamps
    end
  end
end
