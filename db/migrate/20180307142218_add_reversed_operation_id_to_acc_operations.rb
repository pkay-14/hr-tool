class AddReversedOperationIdToAccOperations < ActiveRecord::Migration
  def change
    add_column :acc_operations, :reversed_operation_id, :integer
  end
end
