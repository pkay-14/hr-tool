class CreateAccOperations < ActiveRecord::Migration
  def change
    create_table :acc_operations do |t|
      t.string   "owner_id"
      t.integer  "hours",           default: 0,     null: false
      t.integer  "sum_cents",           default: 0,     null: false
      t.string   "sum_currency",        default: "USD", null: false
      t.date     "operation_date"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "comments"
      t.integer  "status"
      t.string   "master_id"
      t.string   "acceptor_id"
      t.integer  "transaction_type_id"
      t.boolean  "manual",              default: true
    end
  end
end
