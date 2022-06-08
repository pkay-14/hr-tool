class CreateAccSourcebooks < ActiveRecord::Migration
  def change
    create_table :acc_sourcebooks do |t|
      t.string   "owner_id"
      t.string   "master_id"
      t.boolean  "accounting",              default: true
      t.boolean  "social_tax",              default: true
      t.boolean  "rent",                    default: true
      t.boolean  "equipment_rent",          default: true
      t.boolean  "accounting_agency",       default: false
      t.boolean  "trial",                   default: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
