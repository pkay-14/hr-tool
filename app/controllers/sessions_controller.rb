class SessionsController < Devise::SessionsController
  before_action :check_login_url , only: [:login_without_password]
  skip_before_action :check_subdomain

  def login_without_password
    session[:user_id] = User.find(params[:employee_id]).id
    cookies[:user_id] = User.find(params[:employee_id]).id
  end

  def new
    super
  end

  def create
    bookkeeper_sign_in = request.env["omniauth.params"].present? ? request.env["omniauth.params"]['bookkeeper'] : nil
    if bookkeeper_sign_in
      resource = request.env["omniauth.auth"].present? ? Bookeeper.from_omniauth(request.env["omniauth.auth"]) : nil
      if resource
        sign_in(:acc_bookeeper, resource)
        redirect_to acc_edit_dictionaries_path
      else
        redirect_to new_acc_bookeeper_session_path
      end
    else
      resource = ''
      if request.env["omniauth.auth"].present?
        resource = User.from_omniauth(request.env["omniauth.auth"])
      else
        resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
      end
      # if resource.nil? && !resource.is_interviewer? && !resource.is_manager? && !resource.is_hr_manager? && !resource.is_client? && !resource.is_lead?
      if !resource&.is_employee? && !resource&.is_client?
        # signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        set_flash_message :error, :no_access
        respond_to do |format|
          format.all {head :no_content}
          format.any(*navigational_formats) {redirect_to new_user_session_path}
        end
      else
        if resource.has_only_master_role? || request.subdomain == 'masters'
          sign_in(resource_name, resource)
          redirect_to after_sign_in_path_for(resource)
        elsif resource.is_client? || resource.is_lead?
          sign_in(resource_name, resource)
          redirect_to manager_calendar_index_path
        elsif resource.is_admin?
          sign_in(resource_name, resource)
          redirect_to admin_hardwares_path
        else
          # if resource.unattendent_vacations_quantity > 0
          #   redirect_to manager_vacation_approve_index_path
          # else
          sign_in_and_redirect resource
          # end
        end
      end
    end
  end

  def destroy
    current_user&.invalidate_all_sessions!
    super
  end

end

