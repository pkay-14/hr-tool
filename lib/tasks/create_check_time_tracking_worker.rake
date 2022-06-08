task :create_check_time_tracking_worker, [:check_time, :check_day, :check_from, :check_to] => :environment do |t, args|
  args.with_defaults(:check_time => '14:30:00', :check_day => 'Friday', :check_from => nil, :check_to => nil)

  @perform_time = get_perform_time(args[:check_time], args[:check_day])
  from = get_from(args[:check_from])
  to = get_to(args[:check_to])
  p "rake: #{@perform_time} #{from} #{to}"
  CheckTimeTrackingWorker.perform_at(@perform_time, from, to)
end

def get_perform_time(check_time, check_day)
  check_date = Date.parse(check_day)
  check_date -= 1 until Calendar.working_day?(check_date)
  Time.use_zone('Kyiv') { Time.zone.parse("#{check_date} #{check_time}").utc }
end

def get_from(check_from)
  check_from.present? ? Date.parse(check_from) : Date.parse('Friday') - 1.week
end

def get_to(check_to)
  check_to.present? ? Date.parse(check_to) : @perform_time.to_date - 1.day
end

