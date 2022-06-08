class Manager::MasterFeedbacksController < ApplicationController

  layout "admin"

  before_action :set_master

  def new
    @feedback = MasterFeedback.new
  end

  def create
    @feedback = MasterFeedback.create(feedback_params) do |f|
      f.manager = current_user
    end
    redirect_to root_path
  end

  private

    def feedback_params
      params.permit(:text, :master_id, :project_id)
    end

    def set_master
      @master = User.find(params[:master_id])
    end

    # def set_project
      # @project = Project.find(params[:project_id])
    # end

end
