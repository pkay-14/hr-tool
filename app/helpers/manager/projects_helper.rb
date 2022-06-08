module Manager::ProjectsHelper

  def get_total_masters(project)
    active_loads(project).pluck(:employee).compact.uniq.size
  end

  def dev_roles_info(project)
    roles_info = {}
    return roles_info if project.unactive?
    all_roles = active_loads(project).pluck(:dev_role)
    grouped_roles = all_roles.group_by{|role| role}.values
    grouped_roles.each do |group|
      next if group.compact.blank?
      roles_info["#{group.first}"] = group.size
    end
    roles_info
  end

  def active_loads(project)
    project.actual_loads(Date.today, false)
  end
end
