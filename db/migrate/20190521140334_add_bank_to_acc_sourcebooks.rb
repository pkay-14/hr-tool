class AddBankToAccSourcebooks < ActiveRecord::Migration
  def change
    add_column :acc_sourcebooks, :bank, :string
  end
end
