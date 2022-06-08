class Admin::CareerHistoriesController < ApplicationController

  before_action :require_login
  before_action :for_hr_and_master_cabinet, only: [:index]
  before_action :for_hr, only: [:destroy]
  before_action :set_user, only: [:index, :destroy]

  layout "admin"

  def index
    @career_histories = @user.career_histories.recent_first
  end

  def destroy
    CareerHistory.find(params[:id]).destroy
    redirect_to admin_career_histories_path(user_id: @user.id)
  end

  private

  def career_history_params
    params.permit(:id, :user_id)
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def require_login
    if master_cabinet?
      if !user_signed_in? || params[:user_id] != current_user&.id&.to_s
        redirect_to new_user_session_path
      end
    else
      super
    end
  end
end