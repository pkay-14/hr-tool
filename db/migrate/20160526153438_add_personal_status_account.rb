class AddPersonalStatusAccount < ActiveRecord::Migration
  def change
    add_column :acc_accounts, :personal, :boolean
  end
end
