class AddHistoryPersonalFields < ActiveRecord::Migration
  def change
    add_column :acc_balance_histories, :owner_id, :string, index: true
    add_column :acc_balance_histories, :acceptor_id, :string, index: true
  end
end
