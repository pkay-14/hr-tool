class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    head :ok
  end

  def failure
    super
  end

  def moc_id
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user
      # sign_in_and_redirect @user
      sign_in @user
      if @user.is_client? || @user.is_lead?
        redirect_to manager_calendar_index_path
      elsif @user.is_interviewer?
        redirect_to manager_vacation_approve_index_path
      else
        redirect_to admin_employees_path
      end
    else
      redirect_to '/'
    end
  end
end
