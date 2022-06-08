class CreateAccReportRows < ActiveRecord::Migration
  def change
    create_table :acc_report_rows do |t|
      t.string :master_id
      t.integer :year
      t.integer :month
      t.string :report_id
      t.json :row_data
      t.timestamps
    end
  end
end
