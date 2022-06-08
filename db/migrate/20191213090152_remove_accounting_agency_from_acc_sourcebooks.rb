class RemoveAccountingAgencyFromAccSourcebooks < ActiveRecord::Migration
  def change
    remove_column :acc_sourcebooks, :accounting_agency
  end
end
