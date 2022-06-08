require "csv"
desc 'Update annual vacation, sick days and days-off'
task :annual_vacation_days_update => :environment do
  new_masters = User.current_employee.select{|masters|  masters.hired_at&.year == Date.today.year}
  new_masters.each do |new_master|
    new_master.update_attributes(vacation_days_initial: new_master.next_year_vacation_days_remaining_future_master)
    new_master.update_attributes(sick_days: new_master.future_master_sick_days)
  end


  CSV.open("log/vacation_days_lost.csv", "wb") do |csv|
    csv << ["Name", "Vacation days lost"]

    User.current_employee.each do |user|
      unless user.in?(new_masters)
        user.update_attributes(sick_days: user.sick_days_per_year)
        user.update_attributes(vacation_days_initial: user.vacation_days_initial - user.vacation_days_used)
        vacation_days_for_previous_year = user.vacation_days_for_year(Date.today.year - 1)
        if user.vacation_days_initial > vacation_days_for_previous_year
          row_info = []
          row_info << user.full_name
          row_info << user.vacation_days_initial - vacation_days_for_previous_year
          csv << row_info
          user.update_attributes(vacation_days_initial: vacation_days_for_previous_year)
        end
        user.update_attributes(vacation_days_initial: (user.vacation_days_initial - user.next_year_vacation_days_used) + user.vacation_days_per_year)
      end
      user.update_attributes(days_off: 0)
      user.update_attributes(vacation_days_used: 0)
      user.update_attributes(previous_year_vacation_days_remaining: 0)
      user.update_attributes(next_year_vacation_days_used: 0)
    end
  end
end
