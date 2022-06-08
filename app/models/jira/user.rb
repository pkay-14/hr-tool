# == Schema Information
#
# Table name: jira_users
#
#  id         :integer          not null, primary key
#  account_id :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  time_zone  :string(255)
#

module Jira
  class User < ApplicationRecord
    self.table_name = 'jira_users'

    has_and_belongs_to_many :projects, class_name: 'Jira::Project'
    has_many :worklogs

    validates :account_id, presence: true, uniqueness: true
    # validates_presence_of :email

    def group_worklogs_by_date
      self.worklogs.includes(:project).uniq.group_by{|worklog| worklog.date}
    end
  end
end
