require 'mandrill'

class ExportOvertimesWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false
  def perform(overtime_ids, spreadsheet_name, filter_from, filter_to)
    Manager::GoogleSheet.new(spreadsheet_name, filter_from, filter_to).export(overtime_ids)
    p "exporting overtimes"
  end
end
