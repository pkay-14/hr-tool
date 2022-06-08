class CreateAccTimeEntries < ActiveRecord::Migration
  def change
    create_table :acc_time_entries do |t|
      t.integer :month
      t.integer :year
      t.float :time
      t.integer :project_id
      t.integer :redmine_project_id
      t.integer :master_id
      t.integer :redmine_master_id
      t.timestamps
    end
  end
end
