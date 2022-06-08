module Manager
  class TimeTrackingService

    def initialize(from, to)
      self.from = from.to_date
      self.to = to.to_date
    end

    def check_time_tracking
      users = User.current_employee.where(send_time_tracking_reminders: true)
      jira_account_ids = users.pluck(:jira_account_id)
      jira_users = Jira::User.where(account_id: jira_account_ids)
      p "service: #{from} #{to}"

      lazy_users = []
      Country.all.each do |country|
        country_from = from
        country_to = to
        country_from -= 1 until Calendar.working_day?(country_from, country)
        country_to -= 1 until Calendar.working_day?(country_to, country)
        p "#{country}: #{country_from} #{country_to}"
        country_working_days = []
        (country_from..country_to).each {|date| country_working_days << date if Calendar.working_day?(date, country)}
        p "#{country&.name}: #{country_working_days}"

        worklogs = Jira::Worklog.where(user: jira_users).where('date >= ? AND date <= ?', country_from, country_to)
        users.where(country: country).includes(:vacations).each do |user|
          p user.last_name
          p user.moc_email unless user.jira_account_id.present?
          jira_user = jira_users.where(account_id: user.jira_account_id).first
          tracked_time = worklogs.where(user: jira_user).sum(:time_spent_seconds).to_f/3600
          p tracked_time
          norm_time = user.working_days_number(country_working_days)*7.0
          p norm_time
          lazy_users << user if tracked_time < norm_time
        end
      end
      lazy_users.map {|user| user.moc_email}.compact
    end

    private

    attr_accessor :from, :to

  end
end