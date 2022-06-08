class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :acc_invoices do |t|
      t.string :master_id, index: true
      t.string :acceptor_id, index: true
      t.integer :project_id, index: true
      t.money :sum
      t.float :hours
      t.integer :month
      t.integer :year
      t.timestamps
    end
  end
end
