class AddRentToAccSourcebooks < ActiveRecord::Migration[5.2]
  def change
    add_column :acc_sourcebooks, :rent, :string, default: Acc::Sourcebook::RENTS[0]
  end
end
