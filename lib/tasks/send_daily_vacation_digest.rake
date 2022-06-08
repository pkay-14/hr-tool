task :send_daily_vacation_digest, [:check_date] => :environment do |t, args|
  args.with_defaults(:check_date => Date.yesterday.to_s)
  p args[:check_date]
  SendDailyVacationDigestWorker.perform_async("hr@masterofcode.com", args[:check_date])
end
