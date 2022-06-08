module Utils
  module JiraLibrary
    class JiraWorklogLibrary
      def initialize(start_date, end_date)
        @start_date = start_date.to_date
        @end_date = end_date.to_date
        @range = (start_date..end_date)
      end

      def missing_issue_worklogs
        faulty_worklogs('issue_id')
      end


      def missing_project_worklogs
        faulty_worklogs('project_id')
      end

      private

      def faulty_worklogs(field)
        worklogs = Jira::Worklog.where(date: @range, field => nil)
        info = {}
        worklogs.each do |wl|
          date = wl.date.strftime("%d-%m-%Y")
          user = User.where(jira_account_id: wl.user.account_id).first
          next if user.blank?
          info[date].present? ? info[date] += [user.moc_email] : info[date] = [user.moc_email]
        end
        info
      end
    end
  end
end


