class AddSubTypeToAccAccount < ActiveRecord::Migration
  def change
    add_column :acc_accounts, :sub_type, :string
    add_column :acc_accounts, :sub_type_analytical, :string
  end
end
