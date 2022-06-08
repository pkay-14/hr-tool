module UsersHelper
  #def user_status(user)
  #  case user.user_status
  #    when 'suitable' then 'badge badge-success'
  #    when 'doubtful' then 'badge badge-warning'
  #    when 'risky' then 'badge badge-important'
  #    when 'none' then 'badge'
  #  end
  #end

  def user_status(user)
    if user.has_user_status?
      if user.hiring? and user.hired_at and !user.hired_at.blank?
        sanitize "#{user.user_status}<br />(#{user.hired_at})"
      else
        User::USER_STATUSES.include?(user.user_status) ? user.user_status : 'other'
        user.user_status
      end
    end
  end
  def interview_assigned_or_passed(user)
    user.interview_assigned? or user.interview_passed? ? '' : 'hidden'
  end
  def ready_format(string)
    string.gsub(/\n/, '<br>').gsub(/(((http|https):\/\/|www\.)\w{1,}\.\w{1,}((\.|\/|\-)\w{1,})*)/) { |reg| link_to reg,  /^http/.match(reg) ? reg : "http://#{reg}" ,target: '_blank'}
  end

  def user_contacts(user)
    html = ""
    html << "#{user.moc_email}<br/>" if user.moc_email.present?
    html << "#{user.email}<br/>" if user.email.present?
    html << "#{user.tel_number}<br/>"if user.tel_number.present?
    # html << "#{user.contacts}"
    html.gsub(/\n/, '<br>').gsub(/(((http|https):\/\/|www\.)\w{1,}\.\w{1,}((\.|\/|\-)\w{1,})*)/) { |reg| link_to reg,  /^http/.match(reg) ? reg : "http://#{reg}" ,target: '_blank'}
    sanitize html
  end

end
