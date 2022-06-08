class AddOuterInvoiceIdToInvoice < ActiveRecord::Migration
  def change
    add_column :acc_invoices, :outer_invoice_id, :integer
  end
end
