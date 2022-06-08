task :birthday_notification => :environment do
  users = User.all.select { |u| u.birthday == Date.today}
  users_ids = users.map { |u| u.id.to_s }
  SendBirthdayNotificationWorker.perform_async(users_ids) unless users_ids.empty?
end
