class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :acc_accounts do |t|
      t.string :owner_id
      t.string :acc_type
      t.timestamps
    end

    create_table :acc_entries do |t|
      t.integer :debit_account_id, index: true
      t.integer :credit_account_id, index: true
      t.string :owner_id
      t.money :sum
      t.integer :operation_date
      t.timestamps
    end


  end
end
