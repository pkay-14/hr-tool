task :reset_sick_days => :environment do
  require "csv"

  CSV.open("log/sick_days_info.csv", "wb") do |csv|
	csv << ["Name", "Year Norm", "Used Days", "Left Days", "Original Left Days"]

	users = User.current_employee.where(:hired_at.gte => Date.today.at_beginning_of_year)
	users.each do |user|
	  period_start = user.hired_at.day < 11 ? user.hired_at.at_beginning_of_month : user.hired_at.at_beginning_of_month.next_month
	  year_norm = period_start < user.hired_at.at_end_of_year ? (13 - period_start.month) : 0
	  total_used_sick_days = 0
		user.vacations.where(:category => "sick", :status => "approved").each do |vacation|
			used_sick_days = 0
			(vacation.from..vacation.to).each do |day|
				unless (day.saturday? || day.sunday?) || Holiday.where(date: day).any?
					used_sick_days += 1;
				end
			end
			used_sick_days = used_sick_days.to_f
			used_sick_days = (used_sick_days / 2) if vacation.half_day?
			total_used_sick_days += used_sick_days
	  end

	  row_info = []
	  row_info << "#{user.first_name} #{user.last_name}"
	  row_info << year_norm
	  row_info << total_used_sick_days
	  row_info << year_norm - total_used_sick_days
	  row_info << user.sick_days
	  csv << row_info

	  user.sick_days = year_norm - total_used_sick_days
	  user.save
	end

  end

end
