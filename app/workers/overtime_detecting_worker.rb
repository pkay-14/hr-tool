require 'mandrill'

class OvertimeDetectingWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false
  def perform
    Manager::OvertimeTracking.new.detect_overtime
  end
end
