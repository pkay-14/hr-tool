class AddSymbolToAccAccount < ActiveRecord::Migration
  def change
    add_column :acc_accounts, :acc_symbol, :string
  end
end
