class UsersController < ApplicationController

  layout "candidate", :only => [ :pass_questionnaire, :complete_quetionnaire,:account ]

  before_action :set_user
  before_action :require_login
  before_action :for_hr

 # before_action :for_admin, only: [:account,:update]
  def pass_questionnaire
    if @user.candidate_questionnaire.questionnaire_completed?
      render 'users/completed_questionnaire'
    elsif @user.candidate_questionnaire.sent_to_candidate?
      @questions = @user.candidate_questionnaire.get_questions
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  def account
    @user.build_account unless @user.account.present?
  end
  def update
    @user.test_task.skip_scm_url_validation = true if @user.test_task
    p user_params
    if @user.update(user_params)
      p @user.errors
      SendHrAccountNotificationWorker.perform_async(@user.id.to_s)
      respond_to do |format|
        format.html { render action: :account }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    else
      respond_to do |format|
        format.html { render action:  :account  }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end

  end
  def complete_questionnaire
    respond_to do |format|
      @user.candidate_questionnaire.finished!
      HrNotificationWorker.perform_async(@user.id.to_s, topic: :questionnaire_answered)
      format.json { render json: {:result => 'OK'} }
    end
  end

  def get_question
    respond_to do |format|
      if @user.candidate_questionnaire.sent_to_candidate?
        @question = Question.find(params[:question_id])
        @answer =  @user.candidate_questionnaire.get_answer @question
        format.html { render layout: false, partial: 'questions/question_with_answer_form', locals: {question:@question, answer: @answer, user: @user} }
      else
        format.html { head :no_content }
      end
    end
  end

  def send_answer
    respond_to do |format|
      if @user.candidate_questionnaire.sent_to_candidate?
        @question = Question.find(params[:question_id])
        if @user.candidate_questionnaire.set_answer(@question, params[:text])
          format.json { render json: {:result => 'OK'} }
        else
          format.json { head :no_content }
        end
      else
        format.json { head :no_content }
      end
    end
  end

  def check_answers
    respond_to do |format|
      if @user.candidate_questionnaire.sent_to_candidate? and @user.candidate_questionnaire.has_answers_for_all_questions?
        format.json { render json: {:result => 'OK'} }
      else
        format.json { head :no_content }
      end
    end
  end

  def remove_photo
    @user.remove_photo
    respond_to do |format|
      format.js { head 200 }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(
      :last_name, :first_name, :comments, :english_level, :email,
      :moc_email, :tel_number, :skype, :facebook, :linkedin,
      account_attributes:
        [:id, :hipchat_url, :redmine_login, :redmine_password, :git_login, :git_password,
        :email_login,:email_password,:seafile_login,:seafile_password]
      )
  end

end
