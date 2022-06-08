class AddLastEntryMadeDate < ActiveRecord::Migration
  def change
    add_column :acc_entries, :status, :integer
  end
end
