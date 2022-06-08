task :send_previous_year_vacations_notifications => :environment do
  master_ids = User.current_employee.select { |user| user.vacation_days_past_year > 0 && user.moc_email.present?}.
    map { |user| user.id.to_s}
  master_ids.each do |master_id|
    SendPreviousYearVacationsNotificationWorker.perform_async(master_id)
  end

end
