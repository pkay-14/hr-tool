class AddMasterAndAuthenticatorToEntry < ActiveRecord::Migration
  def change
    add_column :acc_entries, :master_id, :string, index: true
    add_column :acc_entries, :acceptor_id, :string, index: true
  end
end
