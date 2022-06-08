class CheckTimeTrackingWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false
  def perform(from, to)
    emails = Manager::TimeTrackingService.new(from, to).check_time_tracking
    emails.each do |email|
      SendTimeTrackingNotificationWorker.perform_async(email)
    end
  end

end
