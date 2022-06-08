class AddTransactionIdToEntry < ActiveRecord::Migration
  def change
    add_column :acc_entries, :transaction_type_id, :integer, index: true
  end
end
