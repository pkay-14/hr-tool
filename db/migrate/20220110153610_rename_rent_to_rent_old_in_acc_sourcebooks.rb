class RenameRentToRentOldInAccSourcebooks < ActiveRecord::Migration[5.2]
  def change
    rename_column :acc_sourcebooks, :rent, :rent_old
  end
end
