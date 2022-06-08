desc 'Pool Utilization regular update'
task :pool_utilization_regular_update, [:from, :to, :type] => :environment do |t, args|
  type = args[:type].present? ? args[:type] : 'date'
  from = if args[:from].present?
           type == 'date' ? args[:from].to_date : Date.today - "#{args[:from]}".to_i.month
         else
           (Date.today - 1.month).beginning_of_month
         end
  to = if args[:to].present?
           type == 'date' ? args[:to].to_date : Date.today + "#{args[:to]}".to_i.month
         else
           Date.today + 6.month
         end

  Rails.logger.info "  Pool Utilization regular update for period: #{from} - #{to} started at #{Time.now}"
  Period.new(from, to).split_by_months.each do |month_period|
    Rails.logger.info "    for month period: #{month_period.from} - #{month_period.to}) at #{Time.now}"
    PoolUtilization::Manager.new(month_period.from, month_period.to).generate
  end
  Rails.logger.info "  Pool Utilization update finished at #{Time.now}"
end

class Period

  attr_accessor :from, :to

  def initialize(from, to)
    self.from = from
    self.to = to
  end

  def split_by_months
    return [] if self.from > self.to
    end_date = [self.from.end_of_month, self.to].min
    [Period.new(self.from, end_date)] + Period.new(end_date.next_day, self.to).split_by_months
  end
end
