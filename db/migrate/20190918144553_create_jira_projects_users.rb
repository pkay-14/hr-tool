class CreateJiraProjectsUsers < ActiveRecord::Migration
  def change
    create_table :jira_projects_users, id: false do |t|
      t.belongs_to :user, class_name: 'Jira::User'
      t.belongs_to :project, class_name: 'Jira::Project'
    end
  end
end
