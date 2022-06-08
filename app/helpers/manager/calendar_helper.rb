module Manager::CalendarHelper
  included Shared

  def user_id(data, user)
    data['jira_users']&.find_by(account_id: user.jira_account_id)&.id
  end

  def project_id(data, project)
    data['jira_projects']&.where('lower(trim(name)) = ?', project.name.downcase.strip).first&.id
  end

  def user_month_time(data, user_id, date)
    return '' unless data.present?
    month = date.beginning_of_month
    key = [user_id, month]
    to_hours(data['month_time'][key])
  end

  def project_date_time(data, user_id=nil, project_id=nil, date)
    return '' unless data.present?
    key = [user_id, project_id, date]
    seconds = data['project_day_time'][key]
    to_hours(seconds)
  end

  def project_month_time(data, user_id, project_id, date)
    return '' unless data.present?
    month = date.beginning_of_month
    user_project = data['users_projects'].find {|h| h['user_id'] == user_id && h['project_id'] == project_id}
    user_project['mapped'] = true if user_project.present?
    key = [user_id, project_id, month]
    to_hours(data['project_month_time'][key])
  end

  def unmapped_user_projects(data, user_id)
    data['users_projects'].find_all {|h| h['user_id'] == user_id && h['mapped'] == false}
  end

  def day_time(data, user_id, date)
    return '' unless data.present?
    key = [user_id, date]
    to_hours(data['day_time'][key])
  end

  def pto_info(pto_data, period)
    case period
    when 'month'
      "PTO #{days_to_hours(pto_data[:month_days])}/#{days(pto_data[:month_days])}"
    when 'year'
      "PTO #{days(pto_data[:year_days])} out of 25d"
    end
  end

end
