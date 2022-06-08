class Admin::EmployeesController < ApplicationController

  before_action :require_login
  before_action :set_user, except: [:index,:index_filters, :create, :new, :employee_for_projects, :clear_career_comment,
                                    :master_info, :social_days_per_year, :offices_list, :get_division_communities,
                                    :get_community_positions, :export]
  before_action :for_hr, except: [:index, :index_filters, :show, :employee_for_projects, :export]
  before_action :for_hr_pm_and_lead, only: [:index, :index_filters, :employee_for_projects]
  before_action :for_hr_pm_lead_and_master_cabinet, only: [:show]
  before_action :set_current_year

  helper_method :division_communities, :community_positions

  layout "admin"

  # GET /users
  # GET /users.json
  def index
    @users = User.current_employee.includes(:loads)
    paginate_users
  end

  def index_filters
    @users = User.includes(:loads).filter_employee_by_params(params)
    paginate_users

   respond_to do |format|
      format.js
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    # return @feedbacks = MasterFeedback.about(@user) unless master_cabinet?

    master_variables
    render 'master_cabinet'
  end

  # GET /users/new
  def new
    country = Country.find_by(name: 'Ukraine')
    @user = User.new(country: country)
    @vacation_days_per_year = country.vacation_days_per_year
    @sick_days_per_year = country.sick_days_per_year
  end

  # GET /users/1/edit
  def edit
    set_career_history_dates
  end

  def create
    if (params[:user][:skills_attributes].present? )
      params[:user][:skills_attributes].each do |k,skill|
        skill[:name] = skill[:name_custom] unless Skill::SKILLS[0..-2].include?(skill[:name])
        skill.delete(:name_custom)
      end
    end
    @user = User.new(user_params.merge(modifier: current_user))
    if @user.save
      unless !user_params[:left_at].blank? or (user_params[:hired_at].empty? and user_params[:user_status] != 'agreement signed')
        @user.add_to_interviewers! unless (params[:user][:is_interviewer] == '0')
        @user.add_to_managers! unless (params[:user][:is_manager] == '0')
        @user.add_role(:employee)
      end
      @user.set_social_days
      params[:user][:is_hr_manager] == '0' ? Role.remove_user_from_role(:hr_manager, @user) : @user.add_to_hr!
      params[:user][:is_lead] == '0' ? Role.remove_user_from_role(:lead, @user) : @user.add_to_lead!
      params[:user][:is_admin] == '0' ? Role.remove_user_from_role(:admin, @user) : @user.add_to_admin!
      MasterWorker.perform_async(@user.id.to_s)
      add_role_and_redirect()
      update_career_history
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    current_career_history = @user.career_histories&.recent_first&.first
    previous_career_history = @user.career_histories&.recent_first&.second
    start_date = current_career_history&.start_date.present? ? current_career_history.start_date : @user.hired_at&.to_date
    end_date = current_career_history&.end_date
    previous_start_date = previous_career_history&.start_date.present? ? previous_career_history&.start_date : @user.hired_at&.to_date
    changes_date = user_params[:changes_date]&.to_date || user_params[:left_at]&.to_date
    conditions_to_restore_master = @user.left_at.present? && (user_params[:left_at].blank? || user_params[:working_status].eql?('Master'))
    check_annual_vac_changes if user_params[:vacation_days_per_year].present?
    if params.dig(:user, :master_cabinet).present?
      if @user.update(user_params.merge(modifier: current_user))
        session[:return_to] ||= request.referer
        redirect_to session.delete(:return_to)
      else
        handle_update_errors
      end
    else
      params[:user][:is_interviewer] == '0' ? Role.remove_user_from_role(:interviewer, @user) : @user.add_to_interviewers!
      params[:user][:is_manager] == '0' ? Role.remove_user_from_role(:manager, @user) : @user.add_to_managers!
      params[:user][:is_hr_manager] == '0' ? Role.remove_user_from_role(:hr_manager, @user) : @user.add_to_hr!
      params[:user][:is_lead] == '0' ? Role.remove_user_from_role(:lead, @user) : @user.add_to_lead!
      params[:user][:is_admin] == '0' ? Role.remove_user_from_role(:admin, @user) : @user.add_to_admin!
      params[:user][:is_hr_lead] == '0' ? Role.remove_user_from_role(:hr_lead, @user) : @user.add_to_hr_lead!
      params[:user][:is_people_partner] == '0' ? Role.remove_user_from_role(:people_partner, @user) : @user.add_to_people_partner!

      params[:user][:changes_date] = @user.changes_date if user_params[:changes_date].blank?

      @user.attributes = user_params.except(:additional_vacations_attributes)
      history_shift_start_date if @user.changes_date_only? && !conditions_to_restore_master && (changes_date > previous_start_date)

      return redirect_without_changes if (changes_date.present? && (start_date > changes_date)) || (conditions_to_restore_master && end_date > changes_date)

      history_position_change if @user.position_changes_only?

      unless (user_params[:position].eql?(@user.position) && user_params[:changes_date].blank?) || user_params[:changes_date].eql?(@user.changes_date)
        update_career_history unless conditions_to_restore_master
      end

      dismiss_master if @user.left_at.blank? && user_params[:left_at].present? || user_params[:working_status].eql?('Ex Master')
      restore_master if conditions_to_restore_master

      @user.reload
      if @user.update(user_params.except(:sick_days))
        @user.set_social_days if @user.hired_at&.year == Date.today.year && @user.left_at.blank?
        @user.update_relations_keywords
        add_role_and_redirect()
      else
        handle_update_errors
      end
    end
  end

  def check_annual_vac_changes
    current_year = Date.today.year
    return if @user.hired_at&.year < current_year || @user.vacation_days_per_year.eql?(user_params[:vacation_days_per_year].to_f)
    @user.update_attributes(vacation_days_per_year: user_params[:vacation_days_per_year])
    year_start_date_for_master = @user.resumed_at.present? ? @user.resumed_at : @user.hired_at
    year_end_date = year_start_date_for_master.end_of_year
    period_start = year_start_date_for_master.day < 11 ? year_start_date_for_master.at_beginning_of_month : year_start_date_for_master.at_beginning_of_month.next_month
    full_working_days = @user.number_of_working_days(period_start, year_end_date)
    vacation_days_initial = (full_working_days * @user.daily_amount_of_vacation_days_to_accumulate).round_to_half
    used_days = @user.count_vacation_days_used(current_year)
    processed = {current_year.to_s => vacation_days_initial - used_days}
    updated_info = @user.annual_vacation_balance.map do |vac_obj|
      vac_obj = processed if vac_obj.keys.first.eql?(current_year.to_s)
      vac_obj
    end
    @user.update_attributes(annual_vacation_balance: updated_info)
  end

  # def ajax_update
  #   @user.update_attributes(ajax_user_params)
  #
  #   respond_to do |format|
  #     format.json {respond_with_bip(@user)}
  #   end
  # end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_employees_url }
      format.json { head :no_content }
    end
  end

  def employee_for_projects
    @users = ActionController::Base.helpers.sanitize User.current_employee.sort_by { |e| e.full_name }.map { |e| { id: e.id.to_s, text: e.full_name } }.to_json
    respond_to do |format|
      format.json { render json: @users }
    end
  end

  def remove_photo
    @user.remove_photo
    respond_to do |format|
      format.js { head 200 }
    end
  end

  # def send_greetings
  #   @user.update_attributes(moc_email: @user.account.email_login)
  #   SendGreetingsWorker.perform_async(@user.id.to_s)
  #   respond_to do |format|
  #     format.html { redirect_to account_admin_employee_path(@user), notice: 'Greetings was send.' }
  #   end
  # end

  # def create_career_meeting
  #   @user = User.find(params[:id])
  #
  #   @meeting = CareerMeeting.create(meeting_params) do |meeting|
  #     meeting.master = @user
  #     meeting.date = Date.today
  #   end
  #
  #   @next_meeting_date = params[:career_meeting][:next_meeting_date]
  #   @user.update_attributes(retrospective_date: @next_meeting_date)
  #
  #   respond_to do |format|
  #      format.js
  #    end
  # end

  def clear_career_comment
      meeting = CareerMeeting.find(params[:id])
      meeting.update_attribute(:comment, '')
      respond_to do |format|
        format.json { render json: { status: "ok" } }
      end
  end



  # def master_info
  #   @master = User.where(moc_email: params[:email]).last
  #   info = {}
  #   if @master
  #     info =  {
  #               avatar_url: view_context.image_url(@master.photo.path(:original).present? ? @master.photo.url(:original) : "user_icon_placeholder@2x.png"),
  #               vacation_days: @master.vacation_days.to_s,
  #               current_managers: @master.managers_today
  #             }
  #   end
  #   render json: info
  # end

  def send_onboarding_email
    if params[:onboarding_date].present?
      SendOnboardingWorker.perform_async(@user.id.to_s, params[:onboarding_date])
      @message = 'The letter has been sent.'
    else
      @message = 'No date is chosen!'
    end
    respond_to do |format|
      format.js
    end
  end

  def social_days_per_year
    country = Country.where(id: user_params['country_id']).first

    data = {}
    data[:vacation_days_per_year] = country&.vacation_days_per_year
    data[:sick_days_per_year] = country&.sick_days_per_year

    respond_to do |format|
      format.json {render json: data}
    end
  end

  def offices_list
    @country = Country.find(params[:country_id])
    @offices = @country.offices
  end

  def get_division_communities
    @division_communities = division_communities(params[:company_division])
  end

  def get_community_positions
    @community_positions = community_positions(params[:community])
  end

  def division_communities(division)
    communities = User::DIVISION_STRUCTURE.select {|el| el[:division] == division}.dig(0, :communities)
    communities.nil? ? [] : communities
  end

  def community_positions(community)
    positions = User::COMMUNITY_STRUCTURE.select {|el| el[:community] == community}.dig(0, :positions)
    positions.nil? ? [] : positions
  end

  def export
    selected_users = User.filter_employee_by_params(params)
    export = Admin::ExportMasters.new(selected_users)
    content = export.to_csv
    send_data content, filename: "Master's Data.csv"
  end
  private

  def set_career_history_dates
    career_history = @user.career_histories&.recent_first&.first
    previous_career_history = @user.career_histories&.recent_first&.second
    @history_start_date = career_history.present? ? career_history.start_date : @user.hired_at&.to_date
    @history_end_date = career_history.present? ? career_history.end_date : nil
    @previous_date = previous_career_history&.present? ? previous_career_history.previous_date : @user.hired_at&.to_date
  end

  def history_shift_start_date
    current_record = @user.career_histories&.recent_first&.first
    return unless current_record.present?

    previous_record = @user.career_histories&.recent_first&.second
    current_record.update(start_date: user_params[:changes_date].to_date)
    return unless previous_record.present?

    previous_record.update(end_date: user_params[:changes_date].to_date - 1) unless previous_record.start_date >= user_params[:changes_date].to_date || previous_record.dismissed
  end

  def history_position_change
    current_record = @user.career_histories&.recent_first&.first
    return unless current_record.present?

    current_record.update(user_params.slice(:position, :community, :company_division))

    send_notifications(current_record) if params.key?(:email_keys) && working_master?
  end

  def restore_master
    resume_career_history

    @user.update_attributes(resumed_at: user_params[:changes_date].to_date, left_at: nil, left_reason: '', left_comment: '')
    @user.set_social_days
  end

  def dismiss_master
    return if user_params[:left_at].blank?

    @user.finish_loads(user_params[:left_at].to_date)
    @user.update_attributes(working_status: "Ex Master")
    @user.clear_social_days
    if @user.is_manager?
      @user.unassign_projects
      @user.process_vacation_approves_after_dismissal
    end
    Role.remove_user_from_role(:interviewer, @user)
    Role.remove_user_from_role(:manager, @user)
    end_career_history
  end

  def update_career_history
    new_master = @user.created_at.strftime('%d/%m/%Y').eql?(Date.today.strftime('%d/%m/%Y'))
    changes_date = params[:user][:changes_date]&.to_date
    return if changes_date.blank? && !new_master

    previous_record = @user.career_histories&.recent_first&.first
    if previous_record.present?
      previous_record.update_attributes(end_date: changes_date - 1) unless previous_record.start_date >= changes_date || previous_record.dismissed
    else
      career_info = {
        position: @user.position,
        community: @user.community,
        company_division: @user.company_division,
        start_date: changes_date || @user.hired_at&.to_date,
        end_date: new_master && @user.career_histories.blank? ? nil : changes_date - 1
      }
      @user.career_histories.create(career_info)
    end
    unless new_master && (@user.career_histories.present? && previous_record&.end_date.nil?)
      career_history = @user.career_histories.find_or_initialize_by(start_date: changes_date)
      career_history.update(user_params.slice(:position, :community, :company_division))

      send_notifications(career_history) if params.key?(:email_keys) && working_master?
    end
  end

  def resume_career_history
    career_info = {
      position: user_params[:position].present? ? user_params[:position] : @user.position,
      community: user_params[:community].present? ? user_params[:community] : @user.community,
      company_division: user_params[:company_division].present? ? user_params[:company_division] : @user.company_division,
      start_date: user_params[:changes_date].to_date,
      end_date: nil
    }
    @user.career_histories.create(career_info)

    send_notifications(@user.career_histories&.recent_first&.first) if params.key?(:email_keys) && working_master?
  end

  def end_career_history
    return unless @user.career_histories.present?
    dismissed_date = user_params[:left_at].to_date
    previous_record = @user.career_histories&.recent_first&.first
    previous_record.update_attributes(end_date: dismissed_date, dismissed: true) unless previous_record.start_date >= dismissed_date
  end

  def send_notifications(career_history)
    return if @user.career_histories.count < 2

    receivers = []
    receivers << 'admin@masterofcode.com' if params[:email_keys].key?(:sysadmin)
    receivers.push(people_partner_email).flatten! if params[:email_keys].key?(:people_partner)
    return if receivers.blank?

    receivers.uniq.compact.each do |email|
      SendCareerHistoryNotificationWorker.perform_async(career_history.id.to_s, email) unless email.eql?(@user.moc_email)
    end
    return unless params[:email_keys].key?(:master)

    SendMasterCareerHistoryNotificationWorker.perform_async(career_history.id.to_s)
  end

  def working_master?
    user_params[:working_status].eql?('Master') || !@user.dismissed?
  end

  def redirect_without_changes
    redirect_to admin_employee_path(@user)
  end

  def handle_update_errors
    Rails.logger.info "employee update errors: #{@user.errors.full_messages}"
    respond_to do |format|
      format.html {render action: 'edit'}
      format.json {render json: @user.errors, status: :unprocessable_entity}
    end
  end

  def set_modifier
    @user.update(modifier: current_user)
  end

  def meeting_params
    params.require(:career_meeting).permit(:comment, :visible_by_managers)
  end
    # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

    # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(
      :user_status,:first_name, :last_name, :first_name_in_ukrainian, :last_name_in_ukrainian, :country_id, :office_id, :hired_at, :left_at, :left_reason,
      :show_in_load_calendar, :send_time_tracking_reminders,:show_non_english_name, :reference, :reference_additional, :contacted_at, :left_comment,
      :email, :sallary, :address,:comments, :people_partner_id, :people_partner, :company_division, :community, :position, :additional_position, :english_level, :moc_email,
      :vacation_days_per_year, :sick_days_per_year, :tel_number, :changes_date, :working_status,
      :technologies, :resume_url, :photo, :retrospective_date, :birthday, :days_off, :sick_days, :is_support,
      skills_attributes: [ :id,:name, :level,:_destroy ], additional_vacations_attributes: [ :id, :days, :comment, :assigned_by, :_destroy ]
      )
  end

  def comment_params
    params.require(:user_comment).permit(:text)
  end

  def add_index_paginate(list)
    i = list.count
    Kaminari.paginate_array(list.map {|k| k.index_number = i ; i-=1; k }).page(params[:page]).per(params[:per_page] ? params[:per_page] : 10)
  end

  def paginate_users
    counter = 1
    @users = Kaminari.paginate_array(@users.map { |u| u.index_number = counter; counter += 1; u }).
      page(params[:page]).per(params[:per_page])
  end

  def people_partner_email
    actual_user = User.find(@user.id)
    people_partners = [actual_user.people_partner&.moc_email]
    people_partners << User.find(user_params[:people_partner_id]).moc_email unless user_params[:people_partner_id].eql?(actual_user.people_partner&.id&.to_s)
    people_partners.uniq
  end

  def set_current_year
    @current_year = Date.today.year
  end

  def require_login
    if master_cabinet?
      if !user_signed_in? || params[:id] != current_user&.id&.to_s
        redirect_to new_user_session_path
      end
    else
      super
    end
  end

  def show_report?
    # return false if @year.to_i == 2021 && @month.to_i >= 12
    # if Date.today.month.in?([3,9]) && (Date.today.beginning_of_month <= Date.new(@year.to_i,@month.to_i,1))
    #   false
    # else
    true
    # end
  end

  def master_variables
    @holidays = Holiday.where(date: (Date.today.beginning_of_year..Date.today.end_of_year), country: @user.country).order_by(date: :asc)
    @year = params[:date].present? ? params[:date][:year] : Date.today.year
    @month = params[:date].present? ? params[:date][:month] : Date.today.month
    @timeoff_details = master_time_off_info
  end

  def master_time_off_info
    additional_vacations = @user.get_additional_vacations(Date.today.year).map{|additional_vac| {'days': additional_vac.days, 'comment': additional_vac.comment }}
    vacation_info = []
    previous_year_earned = @user.earned_vacation_days(Date.new(@current_year - 1).end_of_year)
    current_year_earned = @user.earned_vacation_days - previous_year_earned
    next_year_earned = @user.earned_vacation_days(Date.new(@current_year + 1).beginning_of_year) - @user.remaining_vacation_days_current_year

    #previous year
    if (@user.vacation_days_past_year > 0)
      vacation_info.push({'year': @current_year - 1,
       'earned_vacation': previous_year_earned,
       'available_vacation': @user.vacation_days_past_year,
       'total_for_year': @user.vacation_days_for_year(@current_year - 1)})
    end

    #current_year
    vacation_info.push({'year': @current_year,
    'earned_vacation':  current_year_earned,
    'available_vacation': @user.remaining_vacation_days_current_year,
    'total_for_year': @user.vacation_days_for_year(@current_year)})

    #next year
    vacation_info.push({'year': @current_year + 1,
     'earned_vacation':next_year_earned,
     'available_vacation': @user.next_year_vacation_days_remaining,
     'total_for_year': @user.vacation_days_for_year(@current_year + 1)})

    {
      'vacation_info': vacation_info,
      'additional_vacations': additional_vacations.compact
    }
  end
end
