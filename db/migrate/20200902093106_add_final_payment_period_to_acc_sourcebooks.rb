class AddFinalPaymentPeriodToAccSourcebooks < ActiveRecord::Migration
  def change
    add_column :acc_sourcebooks, :final_payment_period, :date
  end
end
