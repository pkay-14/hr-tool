class AddAccountingToAccSourcebooks < ActiveRecord::Migration
  def change
    add_column :acc_sourcebooks, :accounting, :string
  end
end
