module Manager
  class OvertimeTracking
    def detect_overtime
      overtimers = get_employee_overtimes
      overtimers.each do |employee, overtime_info|
        overtime_info.each do |overtime|
          previous_overtimes = employee.overtimes.where(date: overtime[:date])
          most_recent_overtime = previous_overtimes.recent_first.first if previous_overtimes
          unless overtime[:hours] == most_recent_overtime&.hours
            overtime =  employee.overtimes.create(hours: overtime[:hours], date: overtime[:date],
                                                projects_logged_on_jira: overtime[:project_names],
                                                jira_worklog_ids: overtime[:worklog_ids],
                                                time_logs_attributes: overtime[:detailed_timelog]
                                                )
            overtime.create_approval_request
          end
        end
      end
    end

    private

    def get_employee_overtimes
      overtimers = {}
      User.current_employee.each do |employee|
        jira_account = get_jira_account(employee.jira_account_id)
        grouped_worklog = jira_account.group_worklogs_by_date if jira_account
        valid_worklogs = work_logged_within_range(grouped_worklog)
        overtime = calculate_overtime(employee, valid_worklogs)
        unless overtime.blank?
          overtimers[employee] = overtime
        end
      end
      overtimers
    end

    def calculate_overtime(user, grouped_worklog_hash)
      overtimes = []
      unless grouped_worklog_hash.empty?
        grouped_worklog_hash.each do |date, worklog|
          time_spent_in_seconds = []
          worklog_ids = []
          detailed_timelog = []
          project_names = []
          worklog.each do |worklog_data|
            next if worklog_data.blank?
            time_spent_in_seconds << worklog_data.time_spent_seconds
            project_names << worklog_data.project&.name
            worklog_ids << worklog_data.jira_id
            detailed_timelog << {
              'jira_issue_id': worklog_data.issue_id,
              'time_spent_seconds': worklog_data.time_spent_seconds,
              'worklog_comment':worklog_data.comment
            }
          end
          extra_hours = (time_spent_in_seconds.sum/3600.0) - expected_working_hours(user, date)
          if extra_hours > 0
            overtimes << {'date': date, 'hours': extra_hours, 'project_names': project_names.uniq,
                          'worklog_ids': worklog_ids.uniq, 'detailed_timelog': detailed_timelog}
          end
        end
      end
      overtimes
    end

    def work_logged_within_range(grouped_worklog_hash)
      within_range = {}
      unless grouped_worklog_hash.nil?
        grouped_worklog_hash.each do |date, worklog|
          if date_range.cover?(date)
            within_range[date] = worklog
          end
        end
      end
      within_range
    end

    def get_jira_account(jira_account_id)
      Jira::User.find_by(account_id: jira_account_id) if jira_account_id
    end

    def date_range
      (Date.today - 32..Date.today - 1)
    end

    def expected_working_hours(user, date)
      hours = user.planned_time(date, date)
      expected_hours = hours.empty? ? 0.0 : hours.first[:planned] * 1.0
      expected_hours
    end
  end
end
