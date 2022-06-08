class CreateBalanceHistories < ActiveRecord::Migration
  def change
    create_table :acc_balance_histories do |t|
      t.references :acc_account_id
      t.money :debit_balance
      t.money :credit_balance
      t.date :operational_date
      t.timestamps
    end
  end
end
