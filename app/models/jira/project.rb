# == Schema Information
#
# Table name: jira_projects
#
#  id         :integer          not null, primary key
#  instance   :string(255)
#  jira_id    :string(255)
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

module Jira
  class Project < ApplicationRecord

    self.table_name = 'jira_projects'

    has_and_belongs_to_many :users, class_name: 'Jira::User'
    has_many :worklogs

    validates_presence_of :instance, :jira_id

  end
end
