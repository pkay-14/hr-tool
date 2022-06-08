task :detect_overtimes => :environment do
  puts "Detecting overtimes..."
  Manager::OvertimeTracking.new.detect_overtime
  puts "Overtimes detection complete"
end
