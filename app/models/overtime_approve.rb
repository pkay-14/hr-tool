class OvertimeApprove
  include Mongoid::Document
  include Mongoid::Timestamps

  field :is_approved, type: Boolean
  field :comment, type: String
  field :project_approved_on, type: String
  field :approved_on_date, type: Date

  belongs_to :overtime
  belongs_to :manager , class_name: 'User'

  index({
          manager_id: 1,
          overtime_id: 1,
          is_approved: 1,
        }
  )

  scope :recent_first, -> { order_by(created_at: :desc) }
  scope :recently_updated, -> { order_by(updated_at: :desc) }
  scope :confirmed, -> { where(is_approved: true) }
  scope :dismissed, -> { where(is_approved: false ) }

  #check if remaining apporvers rejected and set overtime status to dismissed
  def check_dismissed
    approve_response = self.overtime.approvers_response.values.uniq
    if approve_response.count == 1 && approve_response.include?(false)
      self.overtime.dismiss_overtime
    end
  end

  #A check before reverting overtime status
  def approver_of_overtime?
    case self.overtime.current_status
    when 'Pending'
      return false
    when 'Confirmed'
      return self.overtime.confirmed_by_approver? ? false : true
    when 'Dismissed'
      return self.overtime.confirmed_by_approver? ? false : true
    end
  end

  def status
    case self.is_approved
    when true
      return 'Confirmed'
    when false
      return 'Dismissed'
    else
      return 'Pending'
    end
  end

  def project_list(show_all = false)
    project_list = ['Select project']
    if self.overtime.overtime_projects.blank?
      current_projects = self.overtime.projects_logged_on_jira.uniq.compact
      project_list += current_projects
    else
      if show_all #for hr view
        current_projects = self.overtime.overtime_projects
        project_list += self.overtime.projects_logged_on_jira.uniq.compact
      else
        current_projects = self.overtime.overtime_projects.select { |project| project.manager == self.manager}
      end
      current_projects.each{|project| project_list << project.name }
    end
    project_list << 'Other'
    project_list.uniq!
    project_list.count == 3 ? project_list - ['Select project'] : project_list
  end

  def canadian?
    self.overtime.employee.country&.name.eql?'Canada'
  end
end
