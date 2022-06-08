class AddInsuranceToAccSourcebooks < ActiveRecord::Migration
  def change
    add_column :acc_sourcebooks, :insurance, :string, default: 'no'
  end
end
