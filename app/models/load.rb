class Load
  include Mongoid::Document
  include Mongoid::Timestamps

  field :from, type: Date
  field :to, type: Date
  field :load , type: Integer, default: 100
  field :comment, type: String
  field :billable, type: Boolean, default: true
  field :dev_role, type: String, default: 'Developer'

  belongs_to :employee, class_name: 'User', touch: true
  belongs_to :project, touch: true
  after_save :touch, :update_project_fte, :update_master_project_info
  before_destroy :touch, :reduce_project_fte, :deduct_load

  PERCENT = [ 0,5,10,15,20,25,30,35,40,45,50,55,60,65,60,65,70,75,80,85,90,95,100 ]
  DEVROLE = %w( Developer Lead QA Designer PM BA Other)
  RANGES = {
    '100% or More' => 100..Float::INFINITY,
    '75%-99%' => 75..99,
    '50%-74%' => 50..74,
    'Less than 50%' => -1..49,
    'Free' => -1..0
  }
  STATUSES = ['Any load', 'Free Soon', 'Selfdev', 'Vacations'].insert(1,RANGES.keys).flatten
  MASTER_CABINET_FILTERS = %w(Mine Team's)
  BILLABLE = { false => 'No', true => 'Yes' }.freeze

  def self.sorted
    all.to_a.sort_by { |load| load.actual? ? 0 : 1 }
  end

  def self.get_role(user_id)
    where(employee_id: user_id).last.dev_role
  end

  def self.get_roles(user_id)
    where(employee_id: user_id).distinct(:dev_role)
  end

  def self.is_not_billable?(user_id, date)
    where(employee_id: user_id, billable: false).or({to: nil}, {:to.gte => date}).present?
  end

  def self.filter_by_date!(loads, date)
    loads&.select! { |load| (load.get_from_date..load.get_to_date).cover?(date) }
  end

  def display_load
    "#{load}%"
  end

  def self.remove_loads_without_master!
    where(employee: nil).destroy_all
  end

  def warning?
    date = Date.today
    employee&.load_level(date, date.day).to_i > 100
  end

  def actual?(date = Date.today)
    (get_from_date(refer_to_project_date: true)..get_to_date(refer_to_project_date: true)).cover?(date)
  end

  def actual_for_month?(date)
    (get_from_date(refer_to_project_date: true)..get_to_date(refer_to_project_date: true)).overlaps?(
      date.beginning_of_month..date.end_of_month)
  end

  def get_from_date(refer_to_project_date: false)
      if refer_to_project_date
        self.from.nil? ? self.project.from || Date.new(2000) : adjust_start_date(self.project.from)
      else
        self.from.nil? ? Date.new(2000) : self.from
      end
  end

  def get_to_date(refer_to_project_date: false)
    if refer_to_project_date
      self.to.nil? ? self.project.to || Date.new(2100) :adjust_end_date(self.project.to)
    else
      self.to.nil? ? Date.new(2100) : self.to
    end
  end

  def adjust_start_date(project_start_date)
    start_date = project_start_date || Date.new(2000)
    self.from < start_date ? start_date : self.from
  end

  def adjust_end_date(project_end_date)
    end_date = project_end_date || Date.new(2100)
    self.to > end_date ? end_date : self.to
  end

  def update_project_fte
    self.project.calculate_fte
  end

  def reduce_project_fte
    self.project.calculate_fte(self)
  end

  def update_master_project_info(remove_load = false)
    master = self.employee
    return if master.blank?
    project_data = {}
    active_projects = master.active_and_support_projects(both: true)
    if active_projects.present?
      active_projects.each do |proj|
        loads = proj.loads.map{|load| load.load if load.employee.eql?(master) && load.actual? && !load.load.eql?(-1)}.compact
        project_data["#{proj.name}"] = loads.sum if loads.sum.positive? && !remove_load
      end
    end
    master.update_attributes(project_info: project_data) unless project_data.eql?(master.project_info)
  end

  def deduct_load
    update_master_project_info(true)
  end
end
