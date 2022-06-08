class AddDescriptionToAccAccount < ActiveRecord::Migration
  def change
    add_column :acc_accounts, :description, :string
  end
end
