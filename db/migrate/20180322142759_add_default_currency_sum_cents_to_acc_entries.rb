class AddDefaultCurrencySumCentsToAccEntries < ActiveRecord::Migration
  def change
    add_column :acc_entries, :default_currency_sum_cents, :integer, default: 0, null: false
  end
end
