class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :acc_sourcebooks, :accounting, :calculate
  end
end
