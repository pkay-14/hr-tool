class AddGroupToAccImportLink < ActiveRecord::Migration
  def change
    add_column :acc_import_links, :tax_group, :integer
  end
end
