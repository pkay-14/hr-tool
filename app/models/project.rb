class Project

  include Mongoid::Document
  include Mongoid::Search
  include Mongoid::Timestamps

  field :name, type: String
  field :status, type: String
  field :category, type: String
  field :comments, type: String
  field :feedback_sent, type: Boolean, default: false
  field :from, type: Date
  field :to, type: Date
  field :position, type: Integer, default: 0

  field :graylog_names, type: String
  field :errbit_keys, type: String
  field :business_domains, type: String
  field :technology_stack, type: String
  field :fte, type: Float, default: 0.0

  field :redmine_url
  field :project_url
  field :description

  belongs_to :manager, class_name: 'User', touch: true
  has_many :loads, order: 'created_at ASC', dependent: :destroy

  has_and_belongs_to_many :tags

  accepts_nested_attributes_for :loads, :reject_if => :all_blank, allow_destroy: true
  validates_uniqueness_of :name, case_sensitive: false

  scope :order_by_name, -> { order_by(name: :asc) }
  after_update :touch
  after_save :touch
  before_destroy :touch
  # paginates_per 15

  search_in :name, tags: :name

  STATUS = ['Active', 'Support', 'Pause', 'Coming Soon', 'Finished', 'Archived']
  STATUSREDMIN = {1 => 'Active',5 => 'Finished', 9 => 'Pause'}
  CATEGORIES = ['Conversational', 'Web and Mobile', 'Own Product', 'LivePerson']

  def send_for_feedbacks!
    SendManagerForFeedbacks.perform_async(self.id.to_s)
    self.update_attributes(feedback_sent: true)
  end

  def self.order_by_manager_name_and_position
    self.all.includes(:manager).sort_by { |p| [p&.manager&.full_name ? 1 : 0, p&.manager&.full_name, p&.position] }
  end

  def self.order_by_params(options)
    return self.order_by_manager_name_and_position unless options[:status_order].present?

    status_order_hash = {}
    if options[:status_order] == 'asc'
      STATUS.each_with_index { |status, index| status_order_hash[status] = index }
    else
      STATUS.reverse.each_with_index { |status, index| status_order_hash[status] = index }
    end
    self.all.includes(:manager).sort_by { |p| [status_order_hash.fetch(p.status, STATUS.size), p&.manager&.full_name ? 1 : 0, p&.manager&.full_name, p.position] }
  end

  def self.filter_by_params(options = {})
    @projects = case options[:manager_id]
                  when 'All'
                    Project.all.includes(:loads)
                  when ''
                    Project.where(manager: nil).includes(:loads)
                  else
                    Project.where(manager: options[:manager_id]).includes(:loads)
                end

    if options[:status] != 'Any status'
      @projects = @projects.where(status: options[:status])
    end

    @projects = @projects.full_text_search(options[:search_query], match: :all) if options[:search_query].present?
    @projects = @projects.order_by_params(options)
  end

  def self.lp_projects_present?(projects)
    return false unless projects.present?

    projects.any? { |project| project.category.eql?('LivePerson') }
  end

  def self.only_lp_projects?(projects)
    return false unless projects.present?

    projects.all? { |project| project.category.eql?('LivePerson') }
  end

  def unactive?
    status == 'Finished' || status == 'Pause' || status == 'Archived'
  end

  def update_year_tags!
    self.tags.category('year').each do |t|
      t.inc(number_of_uses: -1)
    end
    self.tags -= self.tags.category('year')

    from_date = self.from ? self.from : Date.today
    to_date = self.to ? self.to : Date.today

    to_date = from_date if from_date > to_date
    # from_date = to_date if to_date < from_date

    years_list = (from_date..to_date).map(&:year).uniq
    years_list.each do |y|
      t = Tag.find_or_create_by(name: y.to_s, category: 'year')
      t.use!
      self.tags << t
      self.save
    end
  end

  def employee_list
    self.loads.map { |l| l.employee.full_name }.join(', ')
  end

  def employee_moc_email_list
    self.loads.map { |l| l.employee.moc_email }.join(', ')
  end

  def actual_employee_moc_email_list
    actual_load_employees.pluck(:moc_emails).compact
  end

  def actual_employee_names
    actual_load_employees.map{|employee| employee&.full_name}.compact
  end

  def actual_load_employees
    employees = []
    loads.each do |load|
      next unless load.actual? && !unactive? && load&.employee&.moc_email.presence
      employees << load.employee
    end
    employees
  end

  def actual_loads(date, actual_for_month = true, load_to_exclude = nil)
    actual_loads = actual_for_month ? loads.select { |load| load.actual_for_month?(date) } :
                     loads.select { |load| load.actual?(date) }
    actual_loads.delete(load_to_exclude) if load_to_exclude.present?
    loads.in(id: actual_loads)
  end

  def self.graylog_data
    data = {}
    where(:status.ne => 'Archived', :graylog_names.ne => nil).each do |project|
      project.graylog_names.gsub(/\s+/, '').split(',').each do |name|
        data[name] = project.actual_employee_moc_email_list
      end
    end
    data
  end

  def self.errbit_data
    data = {}
    where(:status.ne => 'Archived', :errbit_keys.ne => nil).each do |project|
      data[project.name] ={}
      data[project.name][:keys] = project.errbit_keys.gsub(/\s+/, '').split(',')
      data[project.name][:emails] = project.actual_employee_moc_email_list
    end
    data
  end

  def technology_stack
    self.tags.category('technology').map(&:name).join(', ')
  end

  def active_years
    self.tags.category('year').map(&:name).join(', ')
  end

  def business_domains
    self.tags.category('domain').map(&:name).join(', ')
  end

  def append_tags!(technology_params, business_domains_params)
    (self.tags.category('technology') + self.tags.category('domain')).each do |t|
      t.inc(number_of_uses: -1)
    end
    self.tags = nil
    self.save

    if technology_params
      technology_params.split(', ').each do |tech|
        t = Tag.find_or_create_by(name: tech.to_s, category: 'technology')
        t.use!
        self.tags << t
      end
    end

    if business_domains_params
      business_domains_params.split(', ').each do |domain|
        t = Tag.find_or_create_by(name: domain.to_s, category: 'domain')
        t.use!
        self.tags << t
      end
    end

    self.save
  end

  def actual_for_date?(selected_date)
    (get_from_date.beginning_of_month..get_to_date.end_of_month).include?(selected_date)
  end

  def get_from_date
    self.from.nil? ? Date.new(2000) : self.from
  end

  def get_to_date
    self.to.nil? ? Date.new(2100) : self.to
  end

  def calculate_fte(exclude_load = nil)
    return 0.0 if self.unactive?
    active_loads = self.actual_loads(Date.today, false, exclude_load)
    sum_of_loads = active_loads.sum(&:load)
    new_fte = (sum_of_loads/100.0).round(2)
    self.update_attributes(fte: new_fte) unless new_fte.eql?(self.fte)
  end
end
