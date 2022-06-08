class AddManualToEntry < ActiveRecord::Migration
  def change
    add_column :acc_entries, :manual, :boolean, default: true
  end
end


