module Manager::OvertimesHelper

  def overtimes_photo_link_access(employee)
    if master_cabinet? || current_user.is_admin? && !current_user.is_manager?
      return image_tag(employee_photo(employee), class: 'media-object media-object--break img-circle', alt: 'User photo' )
    end

    link_to image_tag(employee_photo(employee), class: 'media-object media-object--break img-circle', alt: 'User photo' ),
            admin_employee_path(employee), class: 'candidate-name-url'
  end

  def overtimes_name_link_access(employee)

    return employee_full_name(employee) if master_cabinet? || current_user.is_admin? && !current_user.is_manager?

    link_to employee_full_name(employee), admin_employee_path(employee), class: 'candidate-name-url mm-name'
  end

  def previous_time(overtime)
    (overtime.hours + overtime.time_difference).round(2)
  end

  def logged_on_date(overtime)
    overtime.time_difference.negative? ? (overtime.hours - previous_time(overtime)).round(2) : overtime.hours.round(2)
  end

  def operation(overtime)
    overtime.time_difference.negative? ? "by adding #{overtime.time_difference.abs}h to" : "by subtracting #{overtime.time_difference.abs}h from"
  end

  private

  def employee_photo(employee)
    employee.photo.path(:small_retina).present? ? employee.photo.url(:small_retina) : 'user_icon_placeholder@2x.png'
  end
end
