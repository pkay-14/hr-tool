class CreateAccOuterInvoices < ActiveRecord::Migration
  def change
    create_table :acc_outer_invoices do |t|
      t.integer :master_id
      t.integer :month
      t.integer :year
      t.integer :status
      t.text :outer_sync_log
      t.timestamps
    end
  end
end
