class CreateAccProjects < ActiveRecord::Migration
  def change
    create_table :acc_projects do |t|
      t.string :name
      t.integer :uat_acceptor_id, index: true
      t.integer :redmine_id
      t.integer :prosperworks_account_id
      t.timestamps
    end
  end
end
