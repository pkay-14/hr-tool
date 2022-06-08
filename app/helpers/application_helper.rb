module ApplicationHelper
  def link_to_remove_fields (name, f, html_options={})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", html_options)
  end

  def link_to_add_fields(name, f, association, html_options={})

    new_object = f.object.class.reflect_on_association(association).klass.new

    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", html_options)
  end

  def active_page(path)
    current_route = Rails.application.routes.recognize_path(path)
    "active" if current_page?(path) or params[:controller] == current_route[:controller]
  end

  def define_day(date, day, user)
    what_day =  user.what_day?(date, day)
    case what_day
    when "vacation"
      vacation
    when "unpaid leave"
      unpaid_leave
    when "half_day"
      half_day
    when "sick"
      sick
    when "half_day_sick"
      half_day_sick
    when /two halves/
      two_halves(what_day.remove("two halves: "))
    when "booked"
      booked
    when "working"
      day_color(user.load_level(date, day, true))
    when "working,booked"
      day_color(user.load_level(date, day, true),true)
    end
  end

  def define_day_for_project(date, day, user, project)
    case user.what_day?(date, day)
    when 'vacation'
      ''
    when 'half_day', 'half_day_sick'
      load_level = user.load_level_for_project(date, day, project)
      return 'Plan' if load_level == -1
      return load_level.zero? ? '' : "#{load_level/2}%"
    when 'working,booked', 'working'
      load_level = user.load_level_for_project(date, day, project)
      return 'Plan' if load_level == -1
      return load_level.zero? ? '' : "#{load_level}%"
    when 'booked'
      load_level = user.load_level_for_project(date, day, project)
      load_level == -1 ? 'Plan' : ''
    end
  end

  def day_color(load, booked = false)
    percent = load['total_load']
    if percent >= 100
      color_class = (load['billable'] and (load['value'] >= 100)) ? 'high-load' : 'high-load-non-billable'
      content_tag(:div, nil, data:{selector:true, html: true, content:"Load #{percent}% #{'<br /> Plan' if booked}", trigger:'hover', placement:"bottom"}, class: "load-indicator #{color_class}")
    elsif percent >= 50
      content_tag(:div, nil, data:{selector:true, html: true, content:"Load #{percent}% #{'<br /> Plan' if booked}", trigger:'hover', placement:"bottom"}, class: "load-indicator loaded")
    elsif percent >= 25
      content_tag(:div, nil, data:{selector:true, html: true, content:"Load #{percent}% #{'<br /> Plan' if booked}", trigger:'hover', placement:"bottom"}, class: "load-indicator half-loaded")
    else
      content_tag(:div, nil, data:{selector:true, html: true, content:"Load #{percent}% #{'<br /> Plan' if booked}", trigger:'hover', placement:"bottom"}, class: "load-indicator no-load")
    end
  end

  def vacation
    content_tag(:div, nil, data:{selector:true, content:"Vacation", trigger:'hover', placement:"bottom"}, class: "load-indicator vacation")
  end

  def unpaid_leave
    content_tag(:div, nil, data:{selector:true, content:"Unpaid leave", trigger:'hover', placement:"bottom"}, class: "load-indicator vacation")
  end

  def half_day
    content_tag(:div, nil, data:{selector:true, content:"Half-day", trigger:'hover', placement:"bottom"}, class: "load-indicator half-day")
  end

  def sick
    content_tag(:div, nil, data:{selector:true, content:"Sick", trigger:'hover', placement:"bottom"}, class: "load-indicator sick")
  end

  def half_day_sick
    content_tag(:div, nil, data:{selector:true, content:"Half-day sick", trigger:'hover', placement:"bottom"}, class: "load-indicator half-day-sick")
  end

  def two_halves(types)
    vac_types = types.split(',')
    content_tag(:div, nil, data:{selector:true, content:"Half-day #{vac_types[0]} and half-day #{vac_types[1]}", trigger:'hover', placement:"bottom"}, class: "load-indicator half-day-vacation-and-sick")
  end

  def weekend
    content_tag(:div, nil, data:{selector:true, content:"Weekend", trigger:'hover', placement:"bottom"}, class: "load-indicator")
  end

  def compensatory_holiday
    content_tag(:div, nil, data:{selector:true, content:"Compensatory holiday", trigger:'hover', placement:"bottom"}, class: "load-indicator compensatory-holiday")
  end

  def booked
    content_tag(:div, nil, data:{selector:true, content:"Plan", trigger:'hover', placement:"bottom"}, class: "load-indicator booked")
  end

  def jira_date_time(jira_data, date)
    return '' unless jira_data.present?
    jira_date_data = jira_data['day'].find {|h| h['date'] == date.strftime('%d.%m.%y')}
    seconds = jira_date_data.present? ? jira_date_data['seconds'] : 0
    to_hours(seconds)
  end

  def url_params
    url_params = ''
    if master_cabinet?
      url_params += '?master=true'
    end

    if only_master_role?
      url_params += '&only_role=true'
    end
    url_params
  end

  def is_not_dev_env?
    Rails.env.in?(%w[staging pre_production production])
  end

  def time_off_approve_access?
    current_user.is_hr_manager? || current_user.is_manager? || current_user.is_designer? || current_user.is_head_of_marketing? ||
      current_user.is_business_analyst_lead? || current_user.is_infrastructure_leader?
  end

  def switcher_access?
    current_user.is_hr_manager? || current_user.is_manager? || current_user.is_lead? || current_user.is_admin? ||
      current_user.is_business_analyst_lead? || current_user.is_head_of_marketing? || current_user.is_infrastructure_leader?
  end

  def time_off_approves_only?
    current_user.is_head_of_marketing? || current_user.is_infrastructure_leader?
  end
end
