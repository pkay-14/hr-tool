class AddCustomRateFlagToAccount < ActiveRecord::Migration
  def change
    add_column :acc_accounts, :custom_rate, :boolean, default: false
  end
end
