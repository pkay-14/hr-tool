class CreateAccImportLinks < ActiveRecord::Migration
  def change
    create_table :acc_import_links do |t|
      t.integer :redmine_id
      t.string :master_id
      t.timestamps
    end
  end
end
