class AddValidityStatusToAccAccount < ActiveRecord::Migration
  def change

    add_column :acc_accounts, :validity_status, :boolean

  end
end
