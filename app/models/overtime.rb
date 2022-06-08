class Overtime
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Mongoid::History::Trackable
  include Mongoid::Paranoia

  field :date, type: Date
  field :hours, type: Float, default: 0.0
  field :status, type: String
  field :hr_approval_comment, type: String, default: nil
  field :projects_logged_on_jira, type: Array, default: []
  field :jira_worklog_ids, type: Array, default: []
  field :issue_time_log, type: Hash , default: {}
  field :project_approved_on, type: String
  field :approved_on_date, type: Date
  field :time_difference, type: Float
  field :previous_date, type: Date

  belongs_to :employee , class_name: 'User', touch: true
  has_many :approves, class_name: 'OvertimeApprove', dependent: :destroy
  has_many :time_logs, class_name: 'OvertimeTimelog', dependent: :destroy

  accepts_nested_attributes_for :time_logs, allow_destroy: true

  index({
          employee_id: 1,
          approve_ids: 1,
          date: 1,
          status: 1
        }
  )

  track_history   on: [:fields],       # track title and body fields only, default is :all
                  modifier_field: :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  modifier_field_inverse_of: :nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  modifier_field_optional:  true, # marks the modifier relationship as optional
                  version_field: :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  track_create: false,    # track document creation, default is false
                  track_update: true,     # track document updates, default is true
                  track_destroy: true     # track document destruction, default is false

  search_in employee: [:first_name, :last_name]

  scope :by_date, -> { order_by(date: :desc) }
  scope :recent_first, -> { order_by(created_at: :desc) }
  scope :confirmed, -> { where(status: 'confirmed') }
  scope :dismissed, -> { where(status: 'dismissed') }
  scope :pending_modified, -> { where(:time_difference.exists => true, status: nil) }

  paginates_per 10

  def overtime_approvers
    if self.employee.position.in?(['Product Manager', 'Scrum Master', 'LP General Manager', 'Project Manager', 'Project Coordinator'])
      overtime_managers  =  User.pm_overtime_approvers
    else
      projects = self.employee.project_list(date: self.date)
      managers = []
      projects.each{|project| managers << project.manager&.moc_email if project.manager} unless projects.empty?
      managers.compact!
      overtime_managers =  User.current_employee.where({ moc_email: { :$in => managers.uniq }})
    end
    overtime_managers.blank? ? self.employee.get_hiring_manager.to_a.compact : overtime_managers

  end

  def overtime_projects
    logged_projects_in_jira = []
    projects = self.employee.project_list(date: self.date)
    logged_project_names_in_jira = self.projects_logged_on_jira.compact
    unless logged_project_names_in_jira.blank?
      logged_project_names_in_jira.each do |project_name|
        project = Project.where(name: project_name).first
        logged_projects_in_jira << project unless project.nil?
      end
    end
    actual_projects = (projects + logged_projects_in_jira).uniq
    actual_projects
  end

  def project_list
    project_list = ['Select project']
    collected_projects = self.projects_logged_on_jira.uniq.compact
    project_list += collected_projects

    current_projects = self.overtime_projects
    current_projects.each{|project| project_list << project.name }
    project_list << 'Other'
    project_list.uniq!
    project_list.count == 3 ? project_list - ['Select project'] : project_list
  end

  def approve_overtime(comment = nil, project = nil)
    self.update_attributes(status: 'confirmed', hr_approval_comment: comment, project_approved_on: project, approved_on_date: Date.today)
  end

  def dismiss_overtime(comment = nil)
    self.update_attributes(status: 'dismissed', hr_approval_comment: comment, approved_on_date: Date.today)
  end
  def current_status
    self.status.nil? ? "Pending" : self.status.capitalize
  end

  def approved?
    status == 'confirmed'
  end

  def dismissed?
    status == 'dismissed'
  end

  def approvers_response
    responses = {}
    approves.each do |approve|
      responses[approve.manager.full_name] = approve.is_approved
    end
    responses
  end

  def not_approved_managers
    not_approved = approves.where(:is_approved => nil).includes(:manager).map {|approve| approve.manager&.full_name}
    not_approved
  end

  def overtime_approved_by?(user)
    approve = approves.where(manager: user).last
    if approve
      approve.is_approved
    else
      false
    end
  end

  def revert_status
    self.update_attributes(status: nil, project_approved_on: nil, hr_approval_comment: nil, modifier: nil)
  end

  def revert_status_for_hr
    return if self.confirmed_by_approver?
    revert_status
  end

  def create_approval_request
    managers = self.overtime_approvers
    unless managers.blank?
      managers.each do |manager|
        self.approves.create!(manager_id: manager._id)
      end
    end
  end

  def dismissed_approves
    self.approves.dismissed.recently_updated
  end

  def confirmed_approves
    self.approves.confirmed.recently_updated
  end

  def responded_approves
    dismissed_approves | confirmed_approves
  end

  def confirmed_by_approver?
    return false if responded_approves.blank?
    approves_response = self.responded_approves.map{|approves| approves.status}
    if self.current_status == "Confirmed"
      self.current_status.in?(approves_response)
    else
      self.overtime_approvers.count == responded_approves.count ? true : false
    end
  end

  def report_date
    case current_status
    when "Pending"
    self.date.strftime('%d.%m.%Y')
    when "Dismissed"
      if dismissed_approves.empty?
       self.updated_at&.strftime('%d.%m.%Y')
      else
        dismissed_approves.first.updated_at&.strftime('%d.%m.%Y')
      end
    when "Confirmed"
      confirmed_approves.empty? ? self.updated_at&.strftime('%d.%m.%Y') : confirmed_approves.last.updated_at&.strftime('%d.%m.%Y')
    end
  end

  def stringify_project_managers
    stringified_manager_list = ''
    case current_status
    when "Pending"
       not_approved_managers.each{|manager| stringified_manager_list += "#{manager} \n"}
    when "Dismissed"
      self.approves.each do |dismissed|
        stringified_manager_list += "#{dismissed.manager.full_name}\n" unless dismissed.blank?
      end
      unless confirmed_by_approver?
        stringified_manager_list += "dismissed by: #{self.modifier&.full_name.blank? ? 'HR' : self.modifier&.full_name}\n"
      end
    when "Confirmed"
      if self.confirmed_approves.empty?
        self.not_approved_managers.each do |manager|
          stringified_manager_list += "#{manager}\n" unless manager.blank?
        end
        stringified_manager_list += "confirmed by: #{self.modifier&.full_name.blank? ? 'HR' : self.modifier&.full_name } \n"
      else
        stringified_manager_list += "#{self.confirmed_approves.last.manager&.full_name }\n"
      end
    end
    stringified_manager_list
  end

  def stringify_all_approvers
    self.approves.map{|approve| approve.manager&.full_name}.uniq.compact
  end

  def report_comment
    case current_status
    when "Dismissed"
      if dismissed_approves.empty?
        return ["#{self.hr_approval_comment}"]
      else
        if self.confirmed_by_approver?
          dismissed_approves.each do |approver|
            comment_row = []
            unless approver.comment&.blank?
              comment_row << "#{approver.manager.full_name} - #{approver.comment}"
              return comment_row
            else
              return []
            end
          end
        else
          return ["#{self.hr_approval_comment}"]
        end
      end
    when "Confirmed"
      if confirmed_approves.empty?
        "#{self.hr_approval_comment}"
      else
        confirmed_approves.last.comment unless confirmed_approves.last.comment&.empty?
      end
    else
      return nil
    end
  end

  def time_logged_on_issues
    return collected_logged_time unless  collected_logged_time.blank?
    #below is initial implementation. kept to avoid data loss. might decide to be redundant after few months on prod
    time_spent = {}
      time_log = self.issue_time_log
      return time_spent if time_log.blank?
      time_log.each do |issue_id, seconds_logged|
        issue = Jira::Issue.where(id: issue_id.to_i).first
        time_spent[issue] = seconds_logged/3600.0 unless issue.nil?
      end
      time_spent
  end

  def day_time_summarized
    time_logged_on_issues.values.sum.round(2)
  end

  def collected_logged_time
    time_logs = self.time_logs
    return if time_logs.blank?
    time_spent = {}
    time_logs.each do |time_log|
      issue = Jira::Issue.where(id: time_log.jira_issue_id.to_i).first
      unless issue.blank?
        time_spent[issue].present? ? time_spent[issue] += time_log.time_spent_seconds/3600.0 :
          time_spent[issue] = time_log.time_spent_seconds/3600.0
      end
    end
    time_spent
  end

  def issue_url(issue)
    api_url = issue.api_url
    return '#' if api_url.blank?
    base_url = api_url.split('/')[0..2].join('/')
    issue_url = base_url + "/browse/#{issue.key}"
    issue_url
  end

  def canadian?
    self.employee.country&.name.eql?'Canada'
  end
end
