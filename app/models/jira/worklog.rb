# == Schema Information
#
# Table name: jira_worklogs
#
#  id                 :integer          not null, primary key
#  instance           :string(255)
#  user_id            :integer
#  project_id         :integer
#  jira_id            :string(255)
#  date               :date
#  time_spent_seconds :integer
#  created_at         :datetime
#  updated_at         :datetime
#  issue_id           :integer
#

module Jira
  class Worklog < ApplicationRecord
    self.table_name = 'jira_worklogs'

    belongs_to :user, class_name: 'Jira::User'
    belongs_to :project, class_name: 'Jira::Project'
    belongs_to :issue, class_name: 'Jira::Issue'

    validates_presence_of :instance, :jira_id, :date, :time_spent_seconds

    scope :date_between, -> (from, to) { where('date BETWEEN ? AND ?', from, to) }

  end
end
