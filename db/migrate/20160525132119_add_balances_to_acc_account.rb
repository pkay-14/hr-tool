class AddBalancesToAccAccount < ActiveRecord::Migration
  def change
    add_money :acc_accounts, :debit_balance
    add_money :acc_accounts, :credit_balance
  end
end
