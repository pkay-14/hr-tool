# == Schema Information
#
# Table name: jira_issues
#
#  id         :integer          not null, primary key
#  project_id :integer
#  jira_id    :string(255)
#  created_at :datetime
#  updated_at :datetime
#  status     :string
#

module Jira
  class Issue < ApplicationRecord
    self.table_name = 'jira_issues'

    belongs_to :project, class_name: 'Jira::Project'
    has_many :worklogs, class_name: 'Jira::Worklog'

    validates_presence_of :jira_id
  end
end
