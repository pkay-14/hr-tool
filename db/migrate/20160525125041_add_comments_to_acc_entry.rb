class AddCommentsToAccEntry < ActiveRecord::Migration
  def change
    add_column :acc_entries, :comments, :string
  end
end
