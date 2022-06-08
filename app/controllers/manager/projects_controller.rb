class Manager::ProjectsController < ApplicationController
  layout "admin"

  before_action :require_login
  before_action :for_hr_and_pm, except: [:index, :index_filters, :show]
  before_action :for_hr_pm_and_lead, only: [:index, :index_filters, :show]
  before_action :set_project, only: [:update,:destroy, :show, :edit]
  before_action :set_load, only: [:update_load,:destroy_load, :update_load_level]
  before_action :remove_loads_without_master, only: [ :index, :index_filters ]
  before_action :current_managers, only: [ :index, :index_filters, :edit ]
  before_action :clear_cache, only: [ :create_load, :update_load, :update_load_level, :destroy_load, :clear_load_date ]

  def index
    @projects = Project.where(manager: current_user).where(:status.ne => 'Archived').includes(:loads, :tags).order_by_manager_name_and_position
    paginate_projects

    @employee = User.current_employee

    @popular_technologies = Tag.category('technology').popular.map(&:name)
    @popular_domains = Tag.category('domain').popular.map(&:name)
    @popular_years = Tag.category('year').popular.map(&:name)
    hashes_for_bip_forms
  end

  def index_filters
    @projects = Project.filter_by_params(params)
    @manager_id = params[:manager_id]
    paginate_projects

    @employee = User.current_employee
    @employee_for_select2 = ActionController::Base.helpers.sanitize @employee.sort_by { |e| e.full_name }.map { |e| { id: e.id.to_s, text: e.full_name } }.to_json

    hashes_for_bip_forms

    respond_to do |format|
      format.js
    end
  end

  def update_positions
    ids = params[:projects].keys
    Project.find(ids).each do |p|
      p.position = params[:projects][p.id.to_s]
      p.save
    end
    head :ok
  end

  def show
  end

  def edit
  end

  def create
    @project = Project.new(project_params)
    @employee = User.current_employee
    SendProjectLoadNotificationWorker.perform_async('Project',@project.id.to_s) if project_params['name'].present? && @project.save

    render :create_callback
  end

  def update
    if @project.update(project_params)
      SendProjectLoadNotificationWorker.perform_async('Project',@project.id.to_s) if @project.previous_changes['name'].present?

      @project.append_tags!(params[:project][:technology_stack], params[:project][:business_domains])
      @project.update_year_tags!

      if params[:project][:technology_stack] || params[:project][:business_domains]
        redirect_to manager_project_path(@project)
      else
        #render nothing: true, status: 200
        respond_to do |format|
          format.json { respond_with_bip(@project) }
        end
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    if @project.destroy
      head :ok
    else
      head 400
    end
  end

  def create_load
    @load = Load.create({project_id: params[:project_id], from: Date.today})
    if @load.persisted?
      @employee = User.current_employee
      @employee_for_select2 = ActionController::Base.helpers.sanitize @employee.sort_by { |e| e.full_name }.map { |e| { id: e.id.to_s, text: e.full_name } }.unshift({id: '', text: ''}).to_json
      hashes_for_bip_forms
    else
      head 400
    end
  end

  def update_load
    @load.update!(load_params)
    SendProjectLoadNotificationWorker.perform_async('Load',@load.id.to_s) if load_params['employee_id'].present?

    head :ok
  end

  def update_load_level
    @load.update!(load_params)

    respond_to do |format|
      format.json { respond_with_bip(@load) }
    end
    # render json: @load.employee.full_name
  end

  def load_warning
    @load = Load.find(params[:id])

    respond_to do |format|
       format.js
    end
  end

  def clear_load_date
    @load = Load.find(params[:id])
    if params[:date] == 'from'
      @load.from = nil
    elsif params[:date] == 'to'
      @load.to = nil
    end
    @load.save

    respond_to do |format|
       format.js
    end
  end

  def clear_project_date
    @project = Project.find(params[:id])
    if params[:date] == 'from'
      @project.from = nil
    elsif params[:date] == 'to'
      @project.to = nil
    end
    @project.save
    @project.update_year_tags!
    respond_to do |format|
       format.js
    end
  end

  def destroy_load
    if @load.destroy
      head :ok
    else
      head 400
    end
  end

  def send_for_feedbacks
    @project = Project.find(params[:id])
    @project.send_for_feedbacks!

    render :nothing => true ,status: 200
  end

  def export
    projects =  Project.filter_by_params(params)
    content = Manager::ProjectLibrary.new.to_csv(projects)
    send_data content, filename: "Projects Info.csv"
  end

  private

    def set_project
      @project = Project.find(params[:id])
    end

    def set_load
      @load = Load.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:name, :category, :status, :comments, :manager_id, :from, :to,
          :description, :redmine_url, :project_url,:errbit_keys, :graylog_names, :business_domains, :technology_stack
      )
    end

    def load_params
      params.require(:load).permit(:from,:to,:load, :comment,:project_id, :employee_id, :dev_role, :billable)
    end

    def paginate_projects
      @projects = Kaminari.paginate_array(@projects.to_a).page(params[:page]).per(params[:per_page] ? params[:per_page] : 25)
    end

    # Hashes for best in place form. It's impossible to use default rails
    # collection helpers (such as select_tag) for best in places form
    def hashes_for_bip_forms
      @current_managers_bip_hash = Hash[@current_managers.to_a.map { |m| [m.id.to_s, m.full_name] }]
      @current_employee_bip_hash = Hash[@employee.to_a.map { |e| [e.id.to_s, e.full_name] }]
      @loads_list_bip_hash = Hash[Load::PERCENT.to_a.map { |l| [l.to_s, l.to_s + "%"] }]
      @loads_list_bip_hash['-1'] = 'Plan'
      @project_statuses_bip_hash = Hash[Project::STATUS.map { |s| [s.to_s, s.to_s] }]
      @project_categories_bip_hash = Hash[Project::CATEGORIES.map { |s| [s.to_s, s.to_s] }]
      @dev_roles_bip_hash = Hash[Load::DEVROLE.map { |r| [r.to_s, r.to_s] }]
    end

    def remove_loads_without_master
      Load.remove_loads_without_master!
    end

    def current_managers
      @current_managers = User.current_managers
    end

    def clear_cache
      Rails.cache.clear
    end
end
