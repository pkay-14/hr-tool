module Manager::VacationsHelper

  def vacations_photo_link_access(employee)
    if master_cabinet? || current_user.is_admin? && !current_user.is_manager?
      return image_tag((employee.photo.path(:medium).present? ? employee.photo.url(:medium) : 'user_icon_placeholder@2x.png'),
                       class: 'user-img img-circle img-link', alt: 'User photo')
    end

    link_to image_tag((employee.photo.path(:small_retina).present? ? employee.photo.url(:small_retina) : 'user_icon_placeholder@2x.png'),
                      class: 'media-object media-object--break img-circle', alt: 'User photo' ), admin_employee_path(employee), class: 'candidate-name-url'
  end

  def vacations_name_link_access(employee)
    return employee_full_name(employee) if master_cabinet? || current_user.is_admin? && !current_user.is_manager?

    link_to employee_full_name(employee), admin_employee_path(employee), class: 'candidate-name-url mm-name'
  end

  def search_field_conditions
    current_user.is_hr_manager? || current_user.is_lead? || current_user.is_manager?
  end

  def csv_export_conditions
    !master_cabinet? && (current_user.is_hr_manager? || current_user.is_manager?)
  end

  def vacation_request_conditions
    current_user.is_hr_manager? || master_cabinet?
  end

  def full_projects_list
    Project.order_by_name.pluck(:name)
  end

  private

  def employee_full_name(employee)
    employee.full_name.empty? ? 'No Name' : employee.full_name
  end
end
