module Utils
  module JiraLibrary
    class JiraManager

      INSTANCES = JIRA_CONFIGURATION.keys
      MOCG = :mocglobal

      attr_accessor :instance, :webhook_data, :webhook_event

      def initialize(instance: nil, webhook_data: nil)
        self.instance = instance.present? ? instance : INSTANCES
        self.webhook_data = webhook_data
      end

      def data(users, from, to, detailing = 'project', for_db = false)
        if users.present?
          if users.kind_of?(Array)
            jira_user_account_ids = users.map { |user| user.jira_account_id&.strip }&.reject { |jira_account_id| jira_account_id.blank? }.join(',')
          else
            jira_user_account_ids = users.jira_account_id&.strip
          end
        end

        data = []
        return data unless jira_user_account_ids.present?
        fields = "project#{detailing == 'issue' ? ',issuetype,summary,' : ''}#{detailing == 'worklog' ? ',worklog' : ''}"
        fields += ',summary, key, self, customfield_10081, labels' if for_db
        filters = {'from' => from.strftime('%Y/%m/%d'), 'to' => to.strftime('%Y/%m/%d'), 'users' => Array(jira_user_account_ids)}

        Array(instance).each do |instance|
          JiraApiWrapper.configure(instance: instance, token: JIRA_CONFIGURATION[instance])
          data += JiraApiWrapper.data(fields: fields, filters: filters)
        end
        case detailing
        when 'project'
          # projects
          data.map { |issue| issue.dig('fields', 'project', 'name') }.uniq
            .reject { |project| project.downcase.include?('moc_') }
        when 'issue'
          # projects and issues
          data.select { |issue| issue.dig('fields', 'summary').downcase.exclude?('meeting') }
            .map { |issue| {'project' => issue.dig('fields', 'project', 'name'), 'issue_type' => issue.dig('fields', 'issuetype', 'name'), 'issue' => issue.dig('fields', 'summary')} }
            .reject { |hash| hash['project'].downcase.include?('moc_') }
            .group_by { |e| e['project'] }
        when 'worklog'
          # users, projects and hours
          worklog_data(data, from, to, jira_user_account_ids, for_db)
        end
      end

      def worklog_data(issues, from, to, jira_user_account_ids, for_db)
        data = []
        return unless issues.present?
        issues.each do |issue|
          issue.dig('fields', 'worklog', 'worklogs')&.each do |worklog|
            account_id = worklog.dig('author', 'accountId')
            next unless jira_user_account_ids.include?(account_id)
            user_query = "user/search?accountId=#{account_id}"
            user_time_zone = JiraApiWrapper.api_request(user_query).dig(0, 'timeZone')
            date = DateTime.parse(worklog['started']).in_time_zone(user_time_zone).to_date
            next unless date.between?(from, to)
            issue_data = {}
            if for_db
              issue_data['project_id'] = issue.dig('fields', 'project', 'id')
              issue_data['issue_id'] = issue.dig('id')
              issue_data['issue_summary'] = issue.dig('fields', 'summary')
              issue_data['issue_key'] = issue.dig('key')
              issue_data['issue_self'] = issue.dig('self')
              issue_data['issue_label'] = [issue.dig('fields', 'labels', 0), issue.dig('fields', 'customfield_10081', 0)].compact.first
            end
            issue_data['project'] = issue.dig('fields', 'project', 'name')
            issue_data['user_id'] = account_id
            issue_data['user_mapped'] = false
            issue_data['project_mapped'] = false
            worklogs_data = []
            worklog_data = {}
            worklog_data['id'] = worklog['id'] if for_db
            worklog_data['date'] = date
            worklog_data['seconds'] = worklog['timeSpentSeconds']
            worklog_data['comment'] = worklog['comment']
            worklogs_data << worklog_data
            issue_data['worklogs'] = worklogs_data
            data << issue_data
          end
        end

        return data if for_db

        processed_data = []
        group_by = []
        %w(user_id project).each do |grouping|
          group_by << grouping
          grouped_data = group_data(data, group_by)
          processed_data << detail_data(grouped_data, 'day')
        end
        processed_data.flatten.sort_by { |hash| hash['user'] }
      end

      def group_data(data, grouping_fields, summing_fields = ['worklogs'])
        grouped_data = data.group_by { |hash| hash.values_at(*grouping_fields).join ":" }.values.map do |grouped|
          grouped.inject do |merged, n|
            merged.merge(n) do |key, v1, v2|
              if grouping_fields.include?(key)
                v1
              elsif summing_fields.include?(key)
                if v1.respond_to?(:to_i) && v2.respond_to?(:to_i)
                  v1.to_i + v2.to_i
                else
                  v1 + v2
                end
              end
            end
          end
        end

        grouped_data.sort_by { |hash| hash.values_at(*grouping_fields).join ":" }
      end

      def detail_data(grouped_data, detail_by)
        grouped_data.each { |hash| hash[detail_by] = hash['worklogs'].group_by { |b| b["date"].to_date.strftime("%d.%m.%y") }
                                                       .collect { |key, value| {"date" => key, "seconds" => value.sum { |d| d["seconds"].to_i }} }
                                                       .sort_by { |hash| hash['date'].split('.').reverse } }
        grouped_data.each { |hash| hash['total_time'] = hash['worklogs'].map { |s| s['seconds'] }.reduce(0, :+) }
      end

      def handle_webhook
        self.webhook_event = self.webhook_data[:webhookEvent].split('_')
        case self.webhook_event.first
        when 'worklog'
          self.worklog_events
        when 'project'
          self.project_events
        when 'jira:issue'
          self.issue_events
        end
      end

      def get_issue_data(jira_id)
        issue_query = "issue/#{jira_id}"
        JiraApiWrapper.configure(instance: instance, token: JIRA_CONFIGURATION[instance])
        JiraApiWrapper.api_request(issue_query)
      end

      def get_project(project_jira_id, issue_jira_id)
        if project_jira_id.present?
          project = Jira::Project.find_by(jira_id: project_jira_id, instance: instance)
          return project if project.present?
        end

        issue_data = get_issue_data(issue_jira_id)
        project_jira_id ||= issue_data.dig('fields', 'project', 'id')
        if project_jira_id.present?
          project = Jira::Project.find_by(jira_id: project_jira_id, instance: instance)
          return project if project.present?
        end

        name = issue_data.dig('fields', 'project', 'name')
        Jira::Project.create({instance: instance, jira_id: project_jira_id, name: name})
      end

      def get_issue(issue_jira_id, project_jira_id)
        issue = Jira::Issue.find_by(jira_id: issue_jira_id, instance: instance)
        if issue&.onboarding.nil?
          summary = get_issue_data(issue_jira_id).dig('fields', 'summary')
          onboarding = summary&.downcase&.include?('onboarding') ? true : false
          issue.update_attribute(:onboarding, onboarding) if issue.present?
        end
        return issue if issue.present?

        project = get_project(project_jira_id, issue_jira_id)

        issue_opts = { jira_id: issue_jira_id, project_id: project.id, onboarding: onboarding, instance: instance}
        return Jira::Issue.create(issue_opts)
      end

      def worklog_events
        self.instance = self.webhook_data.dig('worklog', 'self').split('https://').last.split('.').first.to_sym
        JiraApiWrapper.configure(instance: instance, token: JIRA_CONFIGURATION[instance])

        account_id = self.webhook_data.dig('worklog', 'author', 'accountId')
        user = Jira::User.find_or_create_by(account_id: account_id)
        user_query = "user/search?accountId=#{account_id}"
        user_time_zone = JiraApiWrapper.api_request(user_query).dig(0,'timeZone')

        project_jira_id = self.webhook_data[:project_id]
        issue_jira_id = self.webhook_data.dig('worklog', 'issueId')
        project = get_project(project_jira_id, issue_jira_id)
        issue = get_issue(issue_jira_id, project_jira_id)
        jira_id = self.webhook_data.dig('worklog', 'id')
        date = DateTime.parse(self.webhook_data.dig('worklog', 'started')).in_time_zone(user_time_zone).to_date
        time_spent_seconds = self.webhook_data.dig('worklog', 'timeSpentSeconds')
        case self.webhook_event.last
        when 'created', 'updated'
          worklog = Jira::Worklog.find_by(jira_id: jira_id, instance: instance) || Jira::Worklog.new
          worklog.instance = instance
          worklog.jira_id = jira_id
          worklog.user = user
          worklog.project = project
          worklog.issue = issue
          worklog.date = date
          worklog.time_spent_seconds = time_spent_seconds
          worklog.save
        when 'deleted'
          worklog = Jira::Worklog.find_by(jira_id: jira_id, instance: instance)
          worklog&.delete
        end
      end

      def project_events
        if self.webhook_event.last == 'updated'
          self.instance = self.webhook_data.dig('project', 'self').split('https://').last.split('.').first
          jira_id = self.webhook_data.dig('project', 'id').to_s
          name = self.webhook_data.dig('project', 'name')

          project = Jira::Project.find_by(jira_id: jira_id, instance: instance) || Jira::Project.new
          project.instance = instance
          project.jira_id = jira_id
          project.name = name
          project.save
        end
      end

      def issue_events
        if self.webhook_data.dig('issue_event_type_name') == 'issue_moved'
          self.instance = self.webhook_data.dig('user', 'self').split('https://').last.split('.').first
          issue_jira_id = self.webhook_data.dig('issue', 'id').to_s
          issue = Jira::Issue.find_by(jira_id: issue_jira_id, instance: instance)
          project = get_project(nil, issue_jira_id)
          if issue.present? && issue.project != project
            issue.update(project: project)
            issue.worklogs.update_all(project_id: project.id)
          end
        end
      end

      def get_account_id(user)
        JiraApiWrapper.configure(instance: self.instance, token: JIRA_CONFIGURATION[self.instance])
        if user.moc_email.present?
          JiraApiWrapper.api_request("user/search?query=#{user.moc_email}").dig(0,'accountId')
        else
          nil
        end
      end

      def self.project_month_time(from_date, to_date)
        worklogs = Jira::Worklog.where('date >= ? AND date <= ?', from_date, to_date).includes(:issue)
        project_month_time = worklogs.where.not(:jira_issues => {onboarding: true}).group(['user_id', 'project_id']).group_by_month(:date, range: from_date..to_date).sum(:time_spent_seconds)
        onboarding_month_time = worklogs.where(:jira_issues => {onboarding: true}).group('user_id').group_by_month(:date, range: from_date..to_date).sum(:time_spent_seconds)
        project_month_time_data = {status: 'Success', data: [], errors: ''}
        project_month_time.merge(onboarding_month_time).each do |ar|
          begin
            account_id = Jira::User.find(ar.dig(0, 0)).account_id
            master = User.find_by(jira_account_id: account_id)
            project_name = ar.dig(0, 1).respond_to?(:to_i) ? Jira::Project.find(ar.dig(0, 1)).name : 'Onboarding'
            project_month_time_data[:data] << {master_name: master.full_name, master_office: master.office.name, master_support: master.is_support, project_name: project_name, time_spent_seconds: ar.dig(1)}
          rescue => error
            project_month_time_data[:status] = 'Failure'
            project_month_time_data[:errors] += "#{error.message.split('.')[0]}. "
          end
        end
        project_month_time_data
      end

    end
  end
end
