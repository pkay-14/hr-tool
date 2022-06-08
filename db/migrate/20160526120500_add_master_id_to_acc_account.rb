class AddMasterIdToAccAccount < ActiveRecord::Migration
  def change
    add_column :acc_accounts, :master_id, :string, index: true
  end
end
