class ChangeOperationDateType < ActiveRecord::Migration
  def change
    change_column :acc_entries, :operation_date, "date USING to_timestamp(operation_date)"
  end
end
