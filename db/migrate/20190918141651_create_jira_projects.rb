class CreateJiraProjects < ActiveRecord::Migration
  def change
    create_table :jira_projects do |t|
      t.string   :instance
      t.string   :jira_id
      t.string   :name
      t.timestamps
    end
  end
end
