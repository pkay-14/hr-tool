# TODO: remove sleep method in production
task :pm_notification => :environment do
  User.current_managers.all.each do |manager|
    PmNotificationWorker.perform_async(manager.id.to_s)
    sleep 2
  end
end
