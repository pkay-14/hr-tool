# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_01_11_091822) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "acc_accounts", force: :cascade do |t|
    t.string "owner_id", limit: 255
    t.string "acc_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "description", limit: 255
    t.string "acc_symbol", limit: 255
    t.integer "debit_balance_cents", default: 0, null: false
    t.string "debit_balance_currency", limit: 255, default: "USD", null: false
    t.integer "credit_balance_cents", default: 0, null: false
    t.string "credit_balance_currency", limit: 255, default: "USD", null: false
    t.string "sub_type", limit: 255
    t.string "sub_type_analytical", limit: 255
    t.boolean "validity_status"
    t.string "master_id", limit: 255
    t.boolean "personal"
    t.boolean "custom_rate", default: false
  end

  create_table "acc_balance_histories", force: :cascade do |t|
    t.integer "acc_account_id_id"
    t.integer "debit_balance_cents", default: 0, null: false
    t.string "debit_balance_currency", limit: 255, default: "USD", null: false
    t.integer "credit_balance_cents", default: 0, null: false
    t.string "credit_balance_currency", limit: 255, default: "USD", null: false
    t.date "operational_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "owner_id", limit: 255
    t.string "acceptor_id", limit: 255
  end

  create_table "acc_entries", force: :cascade do |t|
    t.integer "debit_account_id"
    t.integer "credit_account_id"
    t.string "owner_id", limit: 255
    t.integer "sum_cents", default: 0, null: false
    t.string "sum_currency", limit: 255, default: "USD", null: false
    t.date "operation_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "comments", limit: 255
    t.integer "status"
    t.string "master_id", limit: 255
    t.string "acceptor_id", limit: 255
    t.integer "transaction_type_id"
    t.boolean "manual", default: true
    t.integer "operation_id"
    t.integer "default_currency_sum_cents", default: 0, null: false
  end

  create_table "acc_import_links", force: :cascade do |t|
    t.integer "redmine_id"
    t.string "master_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "tax_group"
  end

  create_table "acc_invoices", force: :cascade do |t|
    t.string "master_id", limit: 255
    t.string "acceptor_id", limit: 255
    t.integer "project_id"
    t.integer "sum_cents", default: 0, null: false
    t.string "sum_currency", limit: 255, default: "USD", null: false
    t.float "hours"
    t.integer "month"
    t.integer "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "outer_invoice_id"
  end

  create_table "acc_operations", force: :cascade do |t|
    t.string "owner_id", limit: 255
    t.integer "hours", default: 0, null: false
    t.integer "sum_cents", default: 0, null: false
    t.string "sum_currency", limit: 255, default: "USD", null: false
    t.date "operation_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "comments", limit: 255
    t.integer "status"
    t.string "master_id", limit: 255
    t.string "acceptor_id", limit: 255
    t.integer "transaction_type_id"
    t.boolean "manual", default: true
    t.integer "reversed_operation_id"
  end

  create_table "acc_outer_invoices", force: :cascade do |t|
    t.integer "master_id"
    t.integer "month"
    t.integer "year"
    t.integer "status"
    t.text "outer_sync_log"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "acc_projects", force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "uat_acceptor_id"
    t.integer "redmine_id"
    t.integer "prosperworks_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "acc_report_rows", force: :cascade do |t|
    t.string "master_id", limit: 255
    t.integer "year"
    t.integer "month"
    t.string "report_id", limit: 255
    t.json "row_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "acc_sourcebooks", force: :cascade do |t|
    t.string "owner_id", limit: 255
    t.string "master_id", limit: 255
    t.boolean "calculate", default: true
    t.boolean "social_tax", default: true
    t.boolean "rent_old", default: true
    t.boolean "equipment_rent", default: true
    t.boolean "trial", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "accounting", limit: 255
    t.string "bank", limit: 255
    t.string "insurance", limit: 255, default: "no"
    t.date "final_payment_period"
    t.string "rent", default: "no"
  end

  create_table "acc_time_entries", force: :cascade do |t|
    t.integer "month"
    t.integer "year"
    t.float "time"
    t.integer "project_id"
    t.integer "redmine_project_id"
    t.integer "master_id"
    t.integer "redmine_master_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "prosperworks_account_id"
  end

  create_table "jira_issues", force: :cascade do |t|
    t.integer "project_id"
    t.string "jira_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "label"
    t.boolean "onboarding"
    t.string "key"
    t.string "summary"
    t.string "api_url"
    t.string "instance"
  end

  create_table "jira_projects", force: :cascade do |t|
    t.string "instance", limit: 255
    t.string "jira_id", limit: 255
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jira_projects_users", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
  end

  create_table "jira_users", force: :cascade do |t|
    t.string "account_id", limit: 255
    t.string "email", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "time_zone", limit: 255
  end

  create_table "jira_worklogs", force: :cascade do |t|
    t.string "instance", limit: 255
    t.integer "user_id"
    t.integer "project_id"
    t.string "jira_id", limit: 255
    t.date "date"
    t.integer "time_spent_seconds"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "issue_id"
    t.string "comment"
  end

end
