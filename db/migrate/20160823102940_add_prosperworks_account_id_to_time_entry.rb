class AddProsperworksAccountIdToTimeEntry < ActiveRecord::Migration
  def change
    add_column :acc_time_entries, :prosperworks_account_id, :integer, index: true
  end
end
