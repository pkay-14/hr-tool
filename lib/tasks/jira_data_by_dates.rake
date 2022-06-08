desc 'Jira data by dates'
task :jira_data_by_dates, [:from, :to, :to_fix] => :environment do |t, args|
  args.with_defaults(from: Date.today.strftime("%d-%m-%Y"), to: Date.today.strftime("%d-%m-%Y"), to_fix: {})

  masters = (User.current_employee + User.recently_left_employee(args[:from].to_date))

  Utils::JiraLibrary::JiraManager::INSTANCES.each do |instance|
    updated = {}
    masters.each do |user|
      if args[:to_fix].present?
        wl_info = args[:to_fix]
        dates = wl_info.keys
        data = []
        dates.each do |date|
          next unless user.moc_email.in?(wl_info[date])
          puts "Fetching #{user.full_name}'s worklogs on #{date} from #{instance}..."  unless updated[date].present? && user.moc_email.in?(updated[date])
          data = data | (Utils::JiraLibrary::JiraManager.new(instance: instance).data(user, date.to_date, date.to_date, 'worklog', true) || [])
          updated[date].present? ? updated[date] << user.moc_email : updated[date] = [user.moc_email]
          puts "Fetched #{user.full_name}'s worklogs on #{date} from #{instance}..."  unless updated[date].present? && user.moc_email.in?(updated[date])
        end
      else
        puts "getting data for #{user.full_name} from #{instance}"
        data = Utils::JiraLibrary::JiraManager.new(instance: instance).data(user, args[:from].to_date, args[:to].to_date, 'worklog', true)
        puts "got data from jira..."
      end

      data&.each do |issue_data|
        account_id = issue_data['user_id']
        user_params = {account_id: account_id}
        user = Jira::User.find_by(user_params)
        unless user.present?
          user = Jira::User.new(user_params)
          notify_on_error(user)
        end

        project_jira_id = issue_data['project_id']
        name = issue_data['project']
        project_params = {jira_id: project_jira_id, instance: instance}
        project = Jira::Project.find_by(project_params) || Jira::Project.new(project_params)
        project.name = name
        notify_on_error(project)

        jira_id = issue_data['issue_id']
        onboarding = issue_data['issue_summary'].downcase.include?('onboarding') ? true : false
        issue = Jira::Issue.find_by(jira_id: jira_id, instance: [instance, nil]) ||
          Jira::Issue.new({jira_id: jira_id})
        issue.instance = instance
        issue.project = project
        issue.summary = issue_data['issue_summary']
        issue.onboarding = onboarding
        issue.key = issue_data['issue_key']
        issue.api_url = issue_data['issue_self']
        issue.label = issue_data['issue_label']

        notify_on_error(issue)

        issue_data['worklogs']&.each do |_worklog|
          jira_id = _worklog['id']
          date = _worklog['date']
          time_spent_seconds = _worklog['seconds']
          comment = _worklog['comment']
          worklog_params = {jira_id: jira_id, instance: instance}
          worklog = Jira::Worklog.find_by(worklog_params) || Jira::Worklog.new(worklog_params)
          worklog.user = user
          worklog.project = project
          worklog.issue = issue
          worklog.date = date
          worklog.time_spent_seconds = time_spent_seconds
          worklog.comment = comment
          notify_on_error(worklog)
        end
      end
    end
  end
end

def notify_on_error(entity)
  if entity.save
    puts "SUCCESS: #{entity.class}"
  else
    puts "ERROR: #{entity.class} messages: #{entity.errors.full_messages}"
  end
end

