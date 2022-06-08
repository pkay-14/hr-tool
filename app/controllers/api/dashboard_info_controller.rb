class Api::DashboardInfoController < Api::ApiController

  before_action :authorize_trusted!

  def projects_for_graylog
    #user = User.where(user_params).first
    render json: Project.graylog_data.to_json
  end

  def user_graylog_projects
    user = User.where(user_params).first
    render json: user.try(:current_projects_for_graylog).to_json
  end

  def projects_for_errbit
    render json: Project.errbit_data.to_json
  end

  def user_errbit_projects
    user = User.where(user_params).first
    p user.try(:current_projects_for_errbit)
    render json: user.try(:current_projects_for_errbit).to_json
  end


  private

  def user_params
    params.permit(:moc_email)
  end


end
