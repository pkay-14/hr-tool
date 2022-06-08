task :reset_vacation_days => :environment do
  require "csv"

  CSV.open("log/vacations_info.csv", "wb") do |csv|
	csv << ["Name", "Year Norm", "Used Days", "Left Days", "Original Left Days"]

	users = User.current_employee.where(:hired_at.gte => Date.today.at_beginning_of_year)
	users.each do |user|
	  vacation_period_start = user.hired_at.day < 11 ? user.hired_at.at_beginning_of_month : user.hired_at.at_beginning_of_month.next_month
	  year_norm = vacation_period_start < user.hired_at.at_end_of_year ? (13 - vacation_period_start.month)*1.5 : 0
	  total_used_vacation_days = 0
		user.vacations.where(:category => "vacation", :status => "approved").each do |vacation|
			used_vacation_days = 0
			(vacation.from..vacation.to).each do |day|
				unless (day.saturday? || day.sunday?) || Holiday.where(date: day).any?
					used_vacation_days += 1;
				end
			end
			used_vacation_days = used_vacation_days.to_f
			used_vacation_days = (used_vacation_days / 2) if vacation.half_day?
			total_used_vacation_days += used_vacation_days
		end

		row_info = []
	  row_info << "#{user.first_name} #{user.last_name}"
	  row_info << year_norm
	  row_info << total_used_vacation_days
	  row_info << year_norm - total_used_vacation_days
	  row_info << user.vacation_days
	  csv << row_info

	  user.vacation_days_initial = year_norm
		user.vacation_days_used = total_used_vacation_days
	  user.save
	end

  end

end
