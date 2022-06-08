module Manager
  CLIENT_SECRETS_PATH = "#{Rails.root}/config/external_services/overtime-reporting-system-service-account.json"

  class GoogleSheet
  require "google_drive"

    def initialize(sheet_name, filter_from, filter_to)
      today = Date.today
      @sheet_name = sheet_name
      @filter_from = filter_from.blank? ? (today - 61).beginning_of_month : filter_from.to_date
      @filter_to = filter_to.blank? ? today.end_of_month : filter_to.to_date

      if filter_from.blank? && filter_to.blank?
        heading_from = @filter_from.strftime('%d/%m/%Y')
        heading_to = @filter_to.strftime('%d/%m/%Y')
      else
        #either the filter_from or filter_to could be blank if user filtered on just one of them
        heading_from = filter_from.blank? ? '' : filter_from.to_date.strftime('%d/%m/%Y')
        heading_to = filter_to.blank? ? '' : filter_to.to_date.strftime('%d/%m/%Y')
      end
      @filter_dates = ['','Date from:', heading_from,'', 'Date to:', heading_to ]
      @headers = ['Overtime Reported (h)', 'Employee', "Employee's Position",'Project Managers', 'Project', 'Actual Load (h)',
                 'Expected Load (h)', 'Overtime acc. to LC (h)', 'Overtime on (DD.MM.YYYY)', 'Reported on (DD.MM.YYYY)',
                 'Approved on (DD.MM.YYYY)', 'Status', 'PM Comments']

    end

    def get_sheet(user_email)
      session = activate_session
      spreadsheet = session.create_spreadsheet(@sheet_name)
      spreadsheet.acl.push({type: "user", email_address: user_email, role: "writer"})

      #for development only
      spreadsheet.acl.push({type: "user", email_address: 'rquaye6x9@gmail.com', role: "writer"}) unless Rails.env.eql?('production')

      worksheet = spreadsheet.worksheets.first
      worksheet.set_background_color(3,1,1, @headers.count, GoogleDrive::Worksheet::Colors::DARK_YELLOW_1)
      worksheet.set_text_format(1,3,1,1,bold:true)
      worksheet.set_text_format(1,6,1,1,bold:true)
      worksheet.set_text_format(3,1,1, @headers.count, bold:true)

      worksheet.insert_rows(1, [@filter_dates, @headers])
      worksheet.insert_rows(2, 1)
      worksheet.save
      spreadsheet.web_view_link
    end

    def export(overtime_ids)
      overtimes = Overtime.where(:id.in => overtime_ids)
      grouped_overtimes = group_overtimes(overtimes)
      paginated_overtimes =  overtime_paginate(grouped_overtimes)
      session = activate_session
      spreadsheet =  session.spreadsheet_by_name(@sheet_name)

      populate(spreadsheet, paginated_overtimes, grouped_overtimes, @filter_from, @filter_to.end_of_day, overtimes.size)
    end

    private

    def populate(spreadsheet, paginated_overtimes, grouped_overtimes, filter_from, filter_to, overtime_size)
      worksheet = spreadsheet.worksheets.first
      worksheet.set_text_alignment(1,1,overtime_size+ (grouped_overtimes.keys).size + 5,@headers.count, horizontal: 'center', vertical: 'middle')

      worksheet_number = 0
      displayed_employees = []
      paginated_overtimes.uniq.each do |employee_emails|
        last_row = worksheet.num_rows
        row_count = last_row + 1
        overtimes_array = []
        employee_emails.each do |employee_email|
          next if employee_email.in?(displayed_employees)
          overtimes = grouped_overtimes[employee_email]
          first_row = first_row(employee_email, overtimes, filter_from, filter_to)
          overtimes_array << first_row
          worksheet.set_text_format(row_count,1,1,@headers.count,bold:true)
          worksheet.set_text_format(row_count,8,1,1,bold:true,foreground_color:GoogleDrive::Worksheet::Colors::RED) if first_row[7].negative?
          row_count += 1
          displayed_employees << employee_email
          overtimes.each do |overtime|
            overtime_row = build_row(overtime: overtime)
            worksheet.set_text_format(row_count,9,1,1,foreground_color:GoogleDrive::Worksheet::Colors::RED) unless (filter_from..filter_to).cover?(overtime.date)
            overtimes_array << overtime_row
            worksheet.set_background_color(row_count,1,1,@headers.count,GoogleDrive::Worksheet::Colors::GRAY)
            row_count += 1
          end
        end
        last_row +=1
        worksheet.insert_rows(last_row, overtimes_array)
        worksheet_number += 1
        worksheet.update_borders(2,1,(worksheet.num_rows),@headers.count,{inner_horizontal: Google::Apis::SheetsV4::Border.new(
            style: "SOLID", color: GoogleDrive::Worksheet::Colors::BLACK)})
        worksheet.update_borders(3,1,(worksheet.num_rows - 2),@headers.count + 1,{inner_vertical: Google::Apis::SheetsV4::Border.new(
            style: "SOLID", color: GoogleDrive::Worksheet::Colors::BLACK)})
        worksheet.save
      end
    end

    def employees_of_overtimes(overtimes)
      overtimes.map{|overtime| overtime.employee&.full_name}.uniq.compact
    end

    def group_overtimes(overtimes)
      overtimes.sort_by{|ov| ov.employee.full_name}.group_by{|ov| ov.employee&.moc_email}
    end

  #set limits of how many overtimes that should be exported in one iteration; result of pagination is an array of grouped
  # employee emails in arrays. Overtimes of employee in each sub array will be exported in the same iteration
    def overtime_paginate(grouped_overtimes)
      limit = 200
      full_list = []
      batch = []
      size = 0
      count = 0
      grouped_overtimes.each do  |key, values|
        if size + values.size <= limit - (batch.size + 1) # +1 is just a buffer for the extra row used by the employee's name
          batch << key
          size += values.size
        else
          full_list << batch.uniq
          full_list << [key]
          size -= size
        end
        count += 1
      end
      full_list << batch.uniq if count.eql?(grouped_overtimes.size)
      full_list
    end

    def first_row(employee_email, overtimes, from, to)
      employee = User.where(moc_email: employee_email).first
      total_hours = overtimes.map{|ov| ov.hours.to_f}.sum.round(2)
      valid_time_logs = valid_logs(employee, from, to)
      actual_load = actual_load(valid_time_logs).round(2)
      expected_load = expected_working_hours(employee, from, to)
      data = {
        total_hours: total_hours,
        employee_name: employee&.full_name,
        employee_position: employee&.position,
        managers: overtimes.first.stringify_all_approvers.join("\n"),
        actual_load: actual_load,
        expected_load: expected_load,
        hours_in_calendar: actual_load - expected_load
      }
      build_row(data, first_row: true)
    end

    def build_row(first_row_data = {}, overtime: nil, first_row: false)
      overtime_row = []
      overtime_row << (first_row ? first_row_data[:total_hours] : overtime.hours.round(2))
      overtime_row << (first_row ? first_row_data[:employee_name] : '') #overtime.employee.full_name
      overtime_row << (first_row ? first_row_data[:employee_position] : '') #overtime.employee.position
      overtime_row << (first_row ? first_row_data[:managers] : overtime.stringify_project_managers)
      projects = ""
      if first_row
        overtime_row << projects
      else
        if overtime.approved?
          if overtime.confirmed_approves.empty?
            projects += overtime.project_approved_on unless overtime.project_approved_on.nil?
          else
            project = overtime.confirmed_approves.last.project_approved_on
            projects += project unless project.nil?
          end
        else
          projects
        end
        overtime_row << projects
      end
      overtime_row << (first_row ? first_row_data[:actual_load] : '') #actual load
      overtime_row << (first_row ? first_row_data[:expected_load] : '') #expected load
      overtime_row << (first_row ? first_row_data[:hours_in_calendar] : '') #hours in load calendar
      overtime_row << (first_row ? '' : overtime.date.strftime('%d.%m.%Y')) #overtime date
      overtime_row << (first_row ? '' : overtime.created_at.strftime('%d.%m.%Y')) #date detected
      overtime&.status.blank? ? overtime_row << '' :  overtime_row << overtime.approved_on_date&.strftime('%d.%m.%Y') #date approved
      overtime_row << (first_row ? '' : overtime.current_status)
      if first_row
        overtime_row << ''
      else
        if overtime.current_status == 'Confirmed'
          overtime_row << overtime.report_comment
        else
          string_comment = ''
          overtime.report_comment.each{|row| string_comment << "#{row} \n"} unless overtime.report_comment.nil?
          overtime_row << string_comment
        end
      end
      overtime_row
    end

    def get_jira_account(jira_account_id)
      Jira::User.find_by(account_id: jira_account_id) if jira_account_id
    end

    def actual_load(grouped_worklog_hash)
      hours = 0
      unless grouped_worklog_hash.empty?
        grouped_worklog_hash.each do |date, worklog|
          time_spent_in_seconds = 0
          worklog.each do |worklog_data|
            time_spent_in_seconds += worklog_data.time_spent_seconds
          end
          hours += time_spent_in_seconds/3600.0
        end
      end
      hours
    end

    def valid_logs(employee, from, to)
      jira_account = get_jira_account(employee.jira_account_id)
      grouped_worklog = jira_account.group_worklogs_by_date if jira_account
      work_logged_within_range(grouped_worklog, from, to)
    end

    def work_logged_within_range(grouped_worklog_hash, from, to)
      within_range = {}
      date_range = from..to
      unless grouped_worklog_hash.nil?
        grouped_worklog_hash.each do |date, worklog|
          if date_range.cover?(date)
            within_range[date] = worklog
          end
        end
      end
      within_range
    end

    def expected_working_hours(user, from, to)
      hours = user.planned_time(from, to)
      hours.map{|block| block[:planned]}.flatten.sum.to_f
    end

    def activate_session
      GoogleDrive::Session.from_config(CLIENT_SECRETS_PATH)
    end
  end
end
