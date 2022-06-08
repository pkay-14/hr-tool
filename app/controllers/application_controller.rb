class ApplicationController < ActionController::Base
  include ApplicationConcern

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :check_subdomain
  # before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :to_hours, :hours_to_days, :days_to_hours, :days

  def after_sign_in_path_for(resource)
    bookkeeper_sign_in = request.env["omniauth.params"].present? ? request.env["omniauth.params"]['bookkeeper'] : nil
    bookkeeper_sign_in ||= params['controller'] == "acc/sessions" ? true : nil
    if bookkeeper_sign_in
      if resource.is_a?(User)
        resource = request.env["omniauth.auth"].present? ? Bookeeper.from_omniauth(request.env["omniauth.auth"]) : nil
        if resource
          sign_in(:acc_bookeeper, resource)
          acc_edit_dictionaries_path
        else
          new_acc_bookeeper_session_path
        end
      else
        request.env['omniauth.origin'] || session[:acc_last_path] || acc_edit_dictionaries_path
      end
    else
      if request.subdomain == 'masters'
        default_path = admin_employee_path(resource.id, {master: true, only_role: true})
      else
        default_path = root_path
      end
      request.env['omniauth.origin'] || session[:last_path] || default_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :acc_bookeeper
      new_acc_bookeeper_session_path
    else
      new_user_session_path
      # respond_to?(:root_path) ? root_path : "/"
    end
  end

  def forbidden
    render status: :forbidden, template: 'admin/errors/403', layout: 'admin'
  end

  private

   def configure_permitted_parameters
     devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:moc_email, :password, :remember_me) }
   end

  def add_role_and_redirect(options = {})
    respond_to do |format|
      if @user.is_candidate?
        @user.change_to_candidate!
        format.html { redirect_to admin_candidate_path(@user) }
        format.json { render json: {status: @user.interview_status, date: @user.interviewed_at ? @user.interviewed_at.strftime("%Y-%m-%d %H:%M") : nil} }
      elsif @user.is_employee? && options[:old_role] == :candidate
        @user.change_to_employee!
        format.html { redirect_to choose_emails_admin_candidate_path(@user) }
      else
        format.html { redirect_to admin_employee_path(@user) }
        format.json {respond_with_bip(@user)}
      end
    end
  end

  def for_hr
    unless (current_user.is_hr_manager?)
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_and_master_cabinet
    return if master_cabinet?
    for_hr
  end

  def for_hr_pm_lead_and_master_cabinet
    return if master_cabinet?
    unless (current_user.is_hr_manager? || current_user.is_manager? || current_user.is_lead?)
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_pm
    unless (current_user.is_hr_manager? || current_user.is_manager? )
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_pm_and_interviewer
    unless (current_user.is_hr_manager? || current_user.is_manager? || current_user.is_interviewer?)
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_pm_designer_interviewer_ba_lead_head_of_marketing_and_infrastructure_leader
    unless current_user.is_hr_manager? || current_user.is_manager? || current_user.is_interviewer? ||
           current_user.is_designer? || current_user.is_business_analyst_lead? || current_user.is_head_of_marketing? ||
           current_user.is_infrastructure_leader?
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_pm_and_people_partner
    unless (current_user.is_hr_manager? || current_user.is_manager? || current_user.is_people_partner? )
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_admin
    unless (current_user.is_admin?)
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_and_admin
    unless (current_user.is_hr_manager? || current_user.is_admin?)
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_and_pm
    unless (current_user.is_hr_manager? || current_user.is_manager? )
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_pm_and_master_cabinet
    return if master_cabinet?
    unless (current_user.is_hr_manager? || current_user.is_manager? )
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_pm_and_lead
    unless (current_user.is_hr_manager? || current_user.is_manager? || current_user.is_lead? || current_user.is_head_of_marketing?)
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_pm_lead_and_master_cabinet
    return if master_cabinet?
    unless (current_user.is_hr_manager? || current_user.is_manager? || current_user.is_lead?)
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_pm_lead_and_designer
    unless (current_user.is_hr_manager? || current_user.is_manager? || current_user.is_lead? || current_user.is_designer?)
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_pm_lead_designer_and_master_cabinet
    return if master_cabinet?
    unless (current_user.is_hr_manager? || current_user.is_manager? || current_user.is_lead? || current_user.is_designer?)
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_and_office_manager
    unless (current_user.is_hr_manager? || current_user.is_office_manager? )
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_pm_and_office_manager
    return if master_cabinet?
    unless (current_user.is_manager? || current_user.is_office_manager? )
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_admins
    unless current_user.is_people_partner? || current_user.is_hr_lead?
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_hr_lead
    unless current_user.is_hr_lead?
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_all
    unless (current_user.is_hr_manager? || current_user.is_manager? || current_user.is_interviewer? || current_user.is_admin? )
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def for_all_except_interviewer
    return if master_cabinet?
    unless (current_user.is_hr_manager? || current_user.is_manager? || current_user.is_admin? || current_user.is_office_manager? ||
        current_user.is_lead?)
      if current_user.is_employee?
        redirect_to "#{admin_employee_path(current_user.id)}?master=true&only_role=true"
      else
        respond_to do |format|
          format.html {render :status => :forbidden, :template => 'admin/errors/403'}
        end
      end
    end
  end

  def for_hr_and_interviewer
    unless (current_user.is_hr_manager? || current_user.is_interviewer? )
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def require_login
    unless user_signed_in?
      # flash[:error] = "You must be logged in to access this section"
      unless ['/admin/candidates/check_uniq', '/admin/employees/employee_for_projects'].include? request.original_fullpath
        if request.xhr?
          session[:last_path] = request.env['HTTP_REFERER']
        else
          session[:last_path] = request.original_url
        end
      end
      respond_to do |format|
        format.html { redirect_to new_user_session_path }
        format.json { head :no_content }
      end
    end
  end

  def check_login
    if user_signed_in?
      unless (current_user.id.to_s == params[:employee_id].to_s)
        respond_to do |format|
          format.html { render :status => :forbidden, :template => 'admin/errors/403' }
        end
      end
    else
      employee = User.where(id: params[:employee_id]).first
      if employee
        sign_in(employee)
      else
        flash[:error] = "Wrong url"
        respond_to do |format|
          format.html { redirect_to new_user_session_path }
          format.json { head :no_content }
        end
      end
    end
  end

  def check_subdomain
    # redirect_to request.original_url unless request.subdomain == 'mm' || (request.subdomain == 'masters' && master_cabinet?)
    unless request.subdomain.in?(%w(mm ppmm)) || (request.subdomain == 'masters' && master_cabinet?)
      respond_to do |format|
        format.html { render :status => :forbidden, :template => 'admin/errors/403' }
      end
    end
  end

  def login_for_managers
    unless user_signed_in?
      employee = User.where(id: params[:employee_id]).first
      if employee
        sign_in(employee)
      else
        flash[:error] = "Wrong url"
        respond_to do |format|
          format.html { redirect_to new_user_session_path }
          format.json { head :no_content }
        end
      end
    end
  end

  def check_login_url
      redirect_to (manager_projects_path) if user_signed_in?
      unless User.where(id: params[:employee_id]).present?
        flash[:error] = "Wrong url"
        respond_to do |format|
          format.html { redirect_to new_user_session_path }
          format.json { head :no_content }
        end
      end
  end

  def to_hours(seconds)
    if seconds.to_i > 0
      hours = (seconds.to_f / 3600).round(1)
      hours = hours.to_i if hours.to_f == hours.to_i
      "#{hours}h"
    else
      ''
    end
  end

  def hours_to_days(hours)
    if hours.to_i > 0
      days = (hours.to_f / 8).round(1)
      days = days.to_i if days.to_f == days.to_i
      "#{days}d"
    else
      '0d'
    end
  end

  def days_to_hours(days)
    if days.to_i > 0
      hours = (days.to_f * 8).round(1)
      hours = hours.to_i if hours.to_f == hours.to_i
      "#{hours}h"
    else
      '0h'
    end
  end

  def days(days)
    if days.to_i > 0
      days = days.to_i if days.to_f == days.to_i
      "#{days}d"
    else
      '0d'
    end
  end
end
