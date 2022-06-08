desc 'Jira data regular update'
task :jira_regular_update, [:hours_ago] => :environment do |t, args|

  Rails.logger.info "  Jira data regular update started at #{Time.now}"

  # set jira_account_id
  users = User.current_employee.where(jira_account_id: nil, send_time_tracking_reminders: true)
  users&.each do |user|
    jira_account_id = Utils::JiraLibrary::JiraManager.new(instance: Utils::JiraLibrary::JiraManager::MOCG).get_account_id(user)
    user.update_attribute(:jira_account_id, jira_account_id) if jira_account_id.present?
  end

  time_ago = args.to_h.fetch(:hours_ago, 25).to_i.hours
  since = (Time.now - time_ago).to_i * 1000

  instances = Utils::JiraLibrary::JiraManager::INSTANCES

  instances.each do |instance|
    JiraApiWrapper.configure(instance: instance, token: JIRA_CONFIGURATION[instance])

    # get created/updated worklogs
    updated_worklogs_ids_url = "worklog/updated?since=#{since}"
    last_page = false
    while last_page == false do
      updated_worklogs = JiraApiWrapper.api_request(updated_worklogs_ids_url)
      updated_worklogs_ids_url = updated_worklogs['nextPage']&.gsub("https://#{instance}.atlassian.net/rest/api/2/",'')
      last_page = updated_worklogs['lastPage']
      if updated_worklogs['values'].present?
        ids = updated_worklogs['values'].map { |el| el['worklogId'] }
        updated_worklogs_data = HTTParty.post("https://#{instance}.atlassian.net/rest/api/2/worklog/list", {
          headers: { 'Content-Type' => 'application/json', 'Authorization' => "Basic #{JIRA_CONFIGURATION[instance]}" },
          :body => {
            "ids": ids
          }.to_json
        }).parsed_response

        if updated_worklogs_data.present?
          issue_ids = updated_worklogs_data.map { |el| el['issueId'] }.map { |el| el.to_i }.uniq.join(',')
          labels = 'labels,customfield_10081'
          row_data_url = "search?fields=project,summary,#{labels}&jql=id in (#{issue_ids})"
          row_data = JiraApiWrapper.paged_data(row_data_url, [])
          if row_data.present?
            project_data = get_project_data(row_data)
            issue_data = get_issue_data(row_data)
            updated_worklogs_data.each do |worklog_data|
              create_data(worklog_data, project_data, issue_data, instance)
            end
          end
        end
      end
    end

    # get deleted worklogs
    deleted_worklogs_ids_url = "worklog/deleted?since=#{since}"
    last_page = false
    while last_page == false do
      deleted_worklogs = JiraApiWrapper.api_request(deleted_worklogs_ids_url)
      deleted_worklogs_ids_url = deleted_worklogs['nextPage']&.gsub("https://#{instance}.atlassian.net/rest/api/2/",'')
      last_page = updated_worklogs['lastPage']
      if deleted_worklogs['values'].present?
        ids = deleted_worklogs['values'].map { |el| el['worklogId'] }
        ids.each do |id|
          worklog = Jira::Worklog.find_by(jira_id: id.to_s, instance: instance)
          if worklog.present?
            log(worklog, 'deleted')
            worklog.destroy
          end
        end
      end
    end

  end

  message = "  Jira regular update finished at #{Time.now}"
  puts message
  Rails.logger.info message
end

def get_project_data(row_data)
  row_data.map do |el|
    {
      'issue_id' => el['id'],
      'project_info' => {'id' => el.dig('fields', 'project', 'id'),
                         'name' => el.dig('fields', 'project', 'name')}
    }
  end
end

def get_issue_data(row_data)
  row_data.map do |el|
    {
      'issue_id' => el['id'],
      'issue_info' => {'summary' => el.dig('fields', 'summary'),
                       'key' => el.dig('key'),
                       'self' => el.dig('self'),
                       'label' => [el.dig('fields', 'labels', 0), el.dig('fields', 'customfield_10081', 0)].compact.first}
    }
  end
end

def create_data(worklog_data, project_data, issue_data, instance)
  account_id = worklog_data.dig('author', 'accountId')
  return nil unless account_id.present?
  user = Jira::User.find_or_create_by(account_id: account_id)
  user_query = "user/search?accountId=#{account_id}"
  user_time_zone = JiraApiWrapper.api_request(user_query).dig(0, 'timeZone')
  log(user)

  project_jira_info = project_data.find { |h| h['issue_id'] == worklog_data['issueId'] }&.dig('project_info')
  return nil unless project_jira_info.present?
  project_params = {jira_id: project_jira_info['id'], instance: instance}
  project = Jira::Project.find_by(project_params) || Jira::Project.new(project_params)
  project.name = project_jira_info['name']
  project.save
  log(project)

  issue_jira_info = issue_data.find { |h| h['issue_id'] == worklog_data['issueId'] }
  return nil unless issue_jira_info.present?
  issue = Jira::Issue.find_by({jira_id: issue_jira_info['issue_id'], instance: [instance, nil]}) ||
    Jira::Issue.new({jira_id: issue_jira_info['issue_id']})
  issue.instance = instance
  issue.project = project
  issue.summary = issue_jira_info&.dig('issue_info','summary')
  issue.onboarding = issue.summary.downcase.include?('onboarding') ? true : false
  issue.key = issue_jira_info&.dig('issue_info','key')
  issue.api_url = issue_jira_info&.dig('issue_info','self')
  issue.label = issue_jira_info&.dig('issue_info','label')
  issue.save
  log(issue)

  return nil unless worklog_data['id'].present?
  worklog_params = {jira_id: worklog_data['id'], instance: instance}
  worklog = Jira::Worklog.find_by(worklog_params) || Jira::Worklog.new(worklog_params)
  worklog.user = user
  worklog.project = project
  worklog.issue = issue
  worklog.date = DateTime.parse(worklog_data['started']).in_time_zone(user_time_zone).to_date
  worklog.time_spent_seconds = worklog_data['timeSpentSeconds']
  worklog.comment = worklog_data['comment']
  worklog.save
  log(worklog)
end

def log(entity, action = nil)
  if entity.previous_changes.present? || action.present?
    action ||= nil.in?(entity.previous_changes.values.flatten) ? 'created' : 'updated'
    message = case entity.class.to_s
              when "Jira::User"
                "#{entity.class} #{entity.account_id} #{action} at #{Time.now}"
              when "Jira::Project"
                "#{entity.class} #{entity.name} #{action} at #{Time.now}"
              when "Jira::Issue"
                "#{entity.class} #{entity.key} #{action} at #{Time.now}"
              when "Jira::Worklog"
                "#{entity.class} #{entity.user.account_id} #{entity.date} #{action} at #{Time.now}"
              end
    puts message
    Rails.logger.info message
  end
end

