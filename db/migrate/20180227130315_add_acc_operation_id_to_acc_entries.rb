class AddAccOperationIdToAccEntries < ActiveRecord::Migration
  def change
    add_column :acc_entries, :operation_id, :integer
  end
end
