require 'csv'
class User

  include Rails.application.routes.url_helpers
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::TaggableWithContext
  include Mongoid::TaggableWithContext::AggregationStrategy::MapReduce
  include Mongoid::Search
  include Mongoid::Paperclip
  include Mongoid::History::Trackable
  include Mongoid::Paranoia
  include Shared

  has_mongoid_attached_file :resume
  validates_attachment_content_type :resume, content_type: %w(
    application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/pdf
    application/rtf
    text/rtf
    application/word
    application/x-msword
    application/x-word
    text/plain
    application/x-rar
    application/x-rar-compressed
    application/octet-stream
    application/zip
    application/x-7z-compressed
  )

  has_mongoid_attached_file :photo,
  :convert_options => { :all => '-background white -flatten +matte' },
  styles: {
    small: ['46x46!', :jpg],
    small_retina: ['94x94!', :jpg],
    medium: ['200x200!', :jpg],
    medium_retina: ['400x400!', :jpg],
    original: ['500x500>', :jpg]
  }

  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  validates_uniqueness_of :moc_email, allow_blank: true
  strip_attributes allow_empty: true

  rolify

  devise :database_authenticatable, :timeoutable,
        :recoverable, :rememberable, :trackable , :omniauthable

  DEV_TECH = %w(Ruby Node.JS Go PHP Python Front-end JS Angular Angular.JS Vue.JS React.JS iOS Android
             Swift Objective-C Kotlin Java Flutter C# C C++ AR Scala)
  TECH = ['Any skills'] + DEV_TECH.sort_by(&:downcase)
  DIVISION_STRUCTURE = [
    { division: 'Delivery', communities: ['Business Analytics', 'Design', 'Conversation Design', 'DevOps',
                                                     'Project Management', 'Quality Assurance', 'General Frontend',
                                          'General Backend', 'Conversational Frontend', 'Conversational Backend',
                                          'Database', 'E-Commerce Frontend', 'E-Commerce Backend', 'Product Management',
                                          'Solution Architecture',  'Mobile', 'Data'].sort_by(&:downcase).freeze},
    { division: 'Business Operations', communities: ['Business Development', 'Finance', 'General Operations',
                                                     'People Operations', 'Recruitment', 'Office Administration',
                                                     'Learning and Development', 'Employer Branding',
                                                     'Security', 'Leadership Team', 'Marketing', 'Infrastructure Administration'].sort_by(&:downcase).freeze},
  ].freeze
  COMMUNITY_STRUCTURE = [
    { community: 'Business Analytics', positions: ['Business Analyst', 'Business Analyst Lead'].sort_by(&:downcase).freeze},
    { community: 'Design', positions: ['UI/UX Designer', 'Graphic Designer', 'Motion Designer'].sort_by(&:downcase).freeze},
    { community: 'Conversation Design', positions: ['Conversation Designer', 'AI Trainer', 'Head of Conversation Design', 'Senior Conversation Designer'].sort_by(&:downcase).freeze},
    { community: 'DevOps', positions: ['DevOps Engineer', 'Infrastructure Leader'].sort_by(&:downcase).freeze},
    { community: 'Project Management', positions: [ 'Project Manager', 'Project Coordinator', 'LP General Manager', 'Scrum Master', 'Solution Delivery Manager'].sort_by(&:downcase).freeze},
    { community: 'Quality Assurance', positions: ['Quality Assurance Engineer'].sort_by(&:downcase).freeze},
    { community: 'General Frontend', positions: ['General Frontend Engineer'].sort_by(&:downcase).freeze},
    { community: 'General Backend', positions: ['General Backend Engineer'].sort_by(&:downcase).freeze},
    { community: 'Conversational Frontend', positions: ['Conversational Frontend Engineer'].sort_by(&:downcase).freeze},
    { community: 'Conversational Backend', positions: ['Conversational Backend Engineer', 'Technical Program Manager'].sort_by(&:downcase).freeze},
    { community: 'Database', positions: ['Database Engineer'].sort_by(&:downcase).freeze},
    { community: 'E-Commerce Frontend', positions: ['E-Commerce Frontend Engineer'].sort_by(&:downcase).freeze},
    { community: 'E-Commerce Backend', positions: ['E-Commerce Backend Engineer'].sort_by(&:downcase).freeze},
    { community: 'Solution Architecture', positions: ['Solution Architect'].sort_by(&:downcase).freeze},
    { community: 'Mobile', positions: ['Android Engineer', 'Cross Platform Engineer', 'iOS Engineer'].sort_by(&:downcase).freeze},
    { community: 'Product Management', positions: ['Product Manager'].sort_by(&:downcase).freeze},

    { community:  'Business Development', positions: ['Business Development Director', 'Product Portfolio Partnerships Director', 'Senior Manager, Sales and Accounts'].sort_by(&:downcase).freeze},
    { community:  'Finance', positions: ['Accountant', 'Finance Controller'].sort_by(&:downcase).freeze},
    { community:  'General Operations', positions: ['Delivery Operations Manager', 'Partnership Manager', 'Director of Technology', 'Partnership Director'].sort_by(&:downcase).freeze},
    { community:  'People Operations', positions: ['Head of People Operations', 'People Partner', 'HR Administrator'].sort_by(&:downcase).freeze},
    { community:  'Recruitment', positions: ['Head of Global Recruitment', 'Recruitment Manager', 'Recruitment IT Researcher'].sort_by(&:downcase).freeze},
    { community:  'Office Administration', positions: ['Office Manager', 'Office Support Manager', 'Security Guard', 'Travel Support Manager'].sort_by(&:downcase).freeze},
    { community:  'Learning and Development', positions: ['English Coach'].sort_by(&:downcase).freeze},
    { community:  'Employer Branding', positions: ['Community Manager', 'Employer Brand Manager', 'Event Manager', 'Project Coordinator for MA', 'Communication Manager'].sort_by(&:downcase).freeze},
    { community:  'Security', positions: ['Information Security Officer', 'Application Security Leader', 'Application Security Engineer'].sort_by(&:downcase).freeze},
    { community:  'Leadership Team', positions: ['Chief Executive Officer', 'Chief Technology Officer', 'Client Delivery Director', 'VP of Engineering'].sort_by(&:downcase).freeze},
    { community:  'Marketing', positions: ['Video Producer', 'Head of Marketing', 'Content and SM Manager', 'Marketing Manager', 'Lead Generation Manager'].sort_by(&:downcase).freeze},
    { community:  'Infrastructure Administration', positions: ['Atlassian Administrator', 'Systems Administrator', 'Security Administrator'].sort_by(&:downcase).freeze},
    { community:  'Data', positions: ['Data Engineer', 'Data Analyst'].sort_by(&:downcase).freeze}
  ].freeze

  COMMUNITIES_HIRING_MANAGERS = [
    {position: 'Client Delivery Director', communities: ['Business Analytics', 'Project Management', 'Product Management'] },
    {position: 'Chief Technology Officer', communities: ['Design','DevOps', 'Quality Assurance', 'General Frontend',
                                                         'General Backend','Conversational Frontend', 'Conversational Backend',
                                                         'Database', 'E-Commerce Frontend', 'E-Commerce Backend',
                                                         'Mobile', 'Security', 'Data']},
    {position: 'VP of Engineering', communities: ['Solution Architecture']},
    {position: 'Chief Executive Officer', communities: ['Business Development', 'Finance', 'General Operations', 'People Operations',
                                                        'Recruitment', 'Office Administration', 'Learning and Development',
                                                        'Employer Branding', 'Marketing', 'Infrastructure Administration', 'Conversation Design']},
  ].freeze
  # POSITIONS = ['SMM Manager', 'Head of HR', 'Tech Lead'].sort_by(&:downcase).freeze
  ENGLISH_LEVELS = %w(none elementary pre-intermediate intermediate upper-intermediate advanced fluent native).freeze
  USER_STATUSES = ['new', 'in review', 'interview 1', 'interview 2', 'interview 3', 'offered', 'agreement signed', 'rejected', 'withdrawn', 'other'].freeze
  MASTER_STATUSES = ['Master', 'Ex Master'].freeze
  NEW_USER_STATUSES = ['interview', 'agreement signed', 'reject'].freeze
  INTERVIEW_STATUSES = %w(none assigned passed rejected).freeze
  REFERENCE = ['', 'MOC website', 'Job Sites', 'Facebook', 'Masters Academy', 'Refferal', 'Events & Conference', 'E-mail hr/careers', 'Other']
  REFERENCE_OPTIONAL = %w(Courses Workshop Event)
  LEFT_REASON = ['resigned', 'fired', 'on maternity' ].freeze
  SEARCH_IN =%w(all name technologies reference).freeze
  ROLES = {
    'any role' => 'Any role',
    'hr_manager' => 'HR',
    'manager' => 'PM',
    'admin' => 'SysAdmin',
    'lead' => 'Lead'
  }.freeze

  CITIES = ['Cherkasy', 'Chernihiv', 'Chernivtsi', 'Dnipro', 'Donetsk', 'Horishni Plavni', 'Ivano-Frankivsk', 'Kharkiv',
            'Kherson', 'Khmelnytskyi', 'Kyiv', 'Kropyvnytskyi', 'Luhansk', 'Lviv', 'Mykolaiv', 'Odesa', 'Orlando', 'Poltava',
            'Rivne', 'Seattle', 'Smila', 'Sumy', 'Ternopil', 'Vinnytsia', 'Lutsk', 'Uzhhorod', 'Winnipeg', 'Zaporizhzhia', 'Zhytomyr'].freeze


  ## Database authenticatable
  field :email,              type: String
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  field :session_token,    type: String

  field :first_name, type: String
  field :first_name_in_ukrainian, type: String
  field :last_name, type: String
  field :last_name_in_ukrainian, type: String
  field :reference, type: String
  field :reference_additional_optional, type: String
  field :reference_additional, type: String
  field :questionnaire_status, type: String
  field :user_status, type: String, default: 'none'
  field :working_status, type: String, default: 'Master'
  field :hired_at, type: DateTime
  field :on_trial, type: Boolean
  field :out_of_load_calendar, type: Boolean, default: false
  field :show_in_load_calendar, type: Boolean, default: true
  field :send_time_tracking_reminders, type: Boolean, default: true
  field :show_non_english_name, type: Boolean, default: false
  field :is_support, type: Boolean, default: false
  field :comments, type: String
  field :english_level, type: String
  field :company_division, type: String
  field :community, type: String
  field :position, type: String
  field :additional_position, type: String
  field :questions, type: Array, default: []
  field :resume_url, type: String
  field :sallary, type: String
  field :contacted_at, type: Time
  field :remote_filename, type: String
  field :remote_dirname, type: String
  field :left_at, type: Date
  field :changes_date, type: Date
  field :left_reason, type: String, default: ''
  field :left_comment, type: String
  field :resumed_at, type: Date
  field :provider, type: String
  field :uid, type: String
  field :trial_notification_worker, type: String
  field :retrospective_date, type: Date

  field :birthday, type: Date
  field :city, type: String
  field :moc_email, type: String
  field :tel_number, type: String
  field :jira_account_id, type: String

  field :pagination_per_page, type: Integer, default: 30

  field :is_signed_contract, type: Boolean, default: false

  # field :resume_id, type: String
  field :vacation_days_per_year, type: Float, default: 0
  field :vacation_days_initial, type: Float, default: 0
  field :future_master_vacation_days_initial, type: Float, default: 0
  field :vacation_days_used, type: Float, default: 0
  field :previous_year_vacation_days_remaining, type: Float, default: 0
  field :next_year_vacation_days_used, type: Float, default: 0
  field :sick_days_per_year, type: Float, default: 0
  field :sick_days, type: Float, default: 0
  field :future_master_sick_days, type: Float, default: 0
  field :days_off, type: Float, default: 0
  field :recent_overtime_report, type: Array, default: nil
  field :last_feedback_session, type: Date
  field :last_performance_evaluation, type: Date
  field :annual_vacation_balance, type: Array, default: []
  field :project_info, type: Hash, default: {}

  # taggable :technologies, separator: ','
  # index({ :name => 1 }, { :unique => true })

  index({first_name: 1, last_name: 1, technologies: 1, phone: 1 ,:email => 1})
  search_in :first_name, :last_name

  belongs_to :country, inverse_of: :masters
  belongs_to :office
  has_many :career_meetings
  has_many :career_histories, dependent: :destroy
  # has_many :master_feedbacks, foreign_key: 'manager_id'

  embeds_many :additional_vacations, cascade_callbacks: true

  # has_many :comments_left, class_name: 'UserComment', foreign_key: 'author_id'
  # has_many :comments_received, class_name: 'UserComment', foreign_key: 'subject_id'
  has_many :loads, foreign_key: 'employee_id'
  has_many :projects, foreign_key: 'manager_id'
  embeds_many :skills
  has_many :vacations, foreign_key: 'employee_id'
  has_many :overtimes, foreign_key: 'employee_id'
  has_many :vacation_approves, class_name: 'VacationApprove', foreign_key: 'manager_id'
  has_many :overtime_approves, class_name: 'OvertimeApprove', foreign_key: 'manager_id'

  belongs_to :hiring_manager, class_name: 'User', inverse_of: :candidates

  belongs_to :people_partner, class_name: 'User', inverse_of: :user

  # TODO: Move order_by to another scope
  scope :candidates, -> { with_role(:candidate).order_by(created_at: :desc) }
  scope :employee_old, -> { with_role(:employee) }
  scope :current_interviewers, -> { where(left_at: nil).with_role(:interviewer).order_by(first_name: :asc) }
  scope :current_managers, -> { where(left_at: nil).with_role(:manager).not.with_role(:hr_test).order_by(first_name: :asc) }
  scope :current_hr_managers, -> { where(left_at: nil).with_role(:hr_manager).not.with_role(:hr_test).order_by(first_name: :asc) }
  scope :current_employee, -> { where(left_at: nil).with_role(:employee).order_by(first_name: :asc) }
  scope :current_employee_for_projects, -> { where(left_at: nil).with_role(:employee).order_by(first_name: :asc) }
  scope :current, -> { where(left_at: nil).order_by(first_name: :asc) }
  scope :left_employee, -> { where(:left_at.ne => nil).order_by(left_at: :desc) }
  scope :recently_left_employee, -> (date = Date.current()-2.months-10.days) { where(:left_at.gte => date) }
  scope :actual_employee_at_date, -> (date) { where(:hired_at.lte => date).any_of({left_at: nil}, {:left_at.gte => date}) }
  scope :not_newcomers, -> { where(:hired_at.lte => 6.months.ago) }
  scope :session_participants, -> { self.or({ :last_feedback_session.lt => 200.days.ago }, { :last_feedback_session => nil }) }
  scope :exclude, -> (master_id) { where(:id.ne => master_id) }
  scope :by_country, -> (country) { where(country: Country.find_by(name: country)) }
  scope :community_leads, ->(community) { where(community: community).with_role(:lead) }


  attr_accessor :index_number
  accepts_nested_attributes_for :skills, :reject_if => proc { |attributes| attributes['name'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :additional_vacations, :reject_if => proc { |attributes| attributes['days']&.to_f&.zero? }, :allow_destroy => true
  embeds_one :account
  accepts_nested_attributes_for :account, :allow_destroy => true

  before_save :change_left_status
  after_save :touch
  before_destroy :touch

  rolify after_add: ->(u,_){ u.touch }, after_remove: ->(u,_){ u.touch }

  def self.history_tracking_fields
    User.fields.keys.map(&:to_sym) - [:sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip]
  end

  # telling Mongoid::History how you want to track changes
  # dynamic fields will be tracked automatically (for MongoId 4.0+ you should include Mongoid::Attributes::Dynamic to your model)
  track_history   on: history_tracking_fields,       # track title and body fields only, default is :all
                  modifier_field: :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  modifier_field_inverse_of: :nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  version_field: :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  track_create: true,    # track document creation, default is false
                  track_update: true,     # track document updates, default is true
                  track_destroy: true     # track document destruction, default is false


  def authenticatable_salt
    "#{super}#{session_token}"
  end

  def invalidate_all_sessions!
    update_attribute(:session_token, SecureRandom.hex)
  end

  def self.filter_employee_by_params(options = {})
    users = case options[:status]
              when 'master'
                options[:role_status].present? ? User.current : User.current_employee
              when 'current_n_recently_left'
                current_employee = options[:role_status].present? ? User.current : User.current_employee
                ids = current_employee.pluck(:id) + User.recently_left_employee.pluck(:id)
                User.in(id: ids)
              else
                if options[:left_since].present?
                  User.recently_left_employee(options[:left_since].to_date)
                else
                  User.left_employee
                end
            end

    if options[:tech].present?
      if options[:tech] == "Developers"
        users = users.developers
      elsif options[:tech] == "Production"
        users = users.production_masters
      elsif options[:tech] != "Any skills"
        users = users.where('skills.name' => options[:tech])
      end
    end

    if options[:office].present?
      users = users.where('office' => Office.find_by(name: options[:office])) if options[:office] != "Any office"
    end
    if options[:company_division].present?
      users = users.where('company_division' =>
                            options[:company_division]) if options[:company_division] != "Any division"
    end
    if options[:community].present?
      users = users.where('community' => options[:community]) if options[:community] != "Any community"
    end
    if options[:position].present?
      users = users.where('position' => options[:position]) if options[:position] != "Any position"
    end

    if options[:people_partner].present?
      if options[:people_partner].capitalize != "Any people partner"
        partner = self.people_partners.select{|people_partner| people_partner if people_partner.full_name == options[:people_partner]}.first
        users = users.where(people_partner: partner)
      end
    end

    if options[:country].present?
      users = users.by_country(options[:country])
    end

    if options[:search_query].present?
        users.merge!(User.full_search(options))
    end

    if options[:role_status].present?
      if options[:role_status].capitalize != "Any role"
        users = users.with_all_roles(:employee, options[:role_status].to_sym)
      else
        users = users.with_role(:employee)
      end
    end

    if options[:order_by].present? && options[:order].present?
      users = User.where(:_id.in => users.map(&:_id))
      users.order_by("#{options[:order_by]} #{options[:order].upcase}, first_name ASC")
    else
      users
    end
  end

  def self.filter_feedback_providers(feedback_providers, feedbacks_in_session, options = {})
    if options[:role].present?
      unless options[:role].eql? 'Any role'
        if options[:role].eql? 'Evaluator'
          evaluator_requests = feedbacks_in_session.by_evaluator
          evaluator_feedback_provider_ids = evaluator_requests.map { |feedback| feedback.evaluator.id }
          feedback_providers = feedback_providers.where(:id.in => evaluator_feedback_provider_ids).order(first_name: :asc, last_name: :asc)
        else
          peer_requests = feedbacks_in_session.by_peer
          peer_feedback_provider_ids = peer_requests.map { |feedback| feedback.peer.id }
          feedback_providers = feedback_providers.where(:id.in => peer_feedback_provider_ids).order(first_name: :asc, last_name: :asc)
        end
      end
    end

    if options[:company_division].present?
      unless options[:company_division].eql? 'Any division'
        feedback_providers = feedback_providers.where(company_division: options[:company_division])
      end
    end

    if options[:people_partner].present?
      unless options[:people_partner].eql? 'Any people partner'
        partner_id = User.people_partners.find_by(first_name: options[:people_partner].split.first, last_name: options[:people_partner].split.last).id
        feedback_providers = feedback_providers.where(people_partner: partner_id)
      end
    end

    if options[:search_query].present?
      unless options[:search_query].empty?
        feedback_providers = feedback_providers.full_text_search(options[:search_query], match: :all)
      end
    end
    feedback_providers
  end

  # User switch case instead if multiple if
  def self.filter_by_legal_status(legal_status)
    if legal_status == 'without_legal_info'
      self.to_a.select { |u| u.is_filled_legal_info == false }
    elsif legal_status == 'without_contract'
      self.to_a.select { |u| u.is_signed_contract == false }
    elsif legal_status == 'with_contract'
      self.to_a.select { |u| u.is_signed_contract == true }
    else
      self
    end
  end

  def self.from_omniauth(auth)
    User.where(moc_email: auth['extra']['id_info']['email']).first
  end

  def self.default_vacation_approver(employee)
    if employee.country.in?(Country.in(name: %w(Canada USA)))
      User.find_by(:moc_email.in => %w(oksana.petrenko@masterofcode.com default_foreign_master_vacation_approver@masterofcode.com))
    else
      User.find_by(:moc_email.in => %w(yuliia.horobets@masterofcode.com default_vacation_approver@masterofcode.com))
    end
  end

  def self.pm_vacation_approver
    User.find_by(:moc_email.in => %w(irina.nikulina@masterofcode.com pm_vacation_approver@masterofcode.com))
  end

  def self.ba_vacation_approver
    User.find_by(:moc_email.in => %w(oleksandr.solunskyi@masterofcode.com ba_lead@masterofcode.com))
  end

  def self.lp_pm_vacation_approver
    User.find_by(:moc_email.in => %w(olga.hrom@masterofcode.com lp_pm_vacation_approver@masterofcode.com))
  end

  def self.pm_overtime_approvers
    User.where(position: 'Delivery Operations Manager')
  end

  def self.lp_project_managers
    User.where(:moc_email.in => %w(
      olga.bayeva@masterofcode.com
      polina.kyrylova@masterofcode.com
      anton.kostiuchenko@masterofcode.com
      olga.hrom@masterofcode.com
      lp_project_manager.hrom@masterofcode.com
    ))
  end

  def self.current_interviewer_old
    self.where(left_at: nil).with_all_roles(:employee, :interviewer).sort_by{|int| int[:first_name]}
  end

  def self.category_search(params)
    query =params[:search_query].split.map{|v| Regexp.new(v, true)}

    case params[:search_in]
      when 'name'
        self.any_of({:first_name.in => query},{:last_name.in =>query} )
      when 'technologies'
        self.in(:technologies => query)
      when 'contacts'
        self.any_of({:email.in => query})
      when 'reference'
        self.any_of({:reference.in => query},{:reference_additional.in => query} )
    end
  end

  def self.filter_by_params(options = {})
    date = options[:date].to_date
    if date.month != Date.today.month
      date = date > Date.today ? date.beginning_of_month : date.end_of_month
    end

    if options['masters_for_load_calendar'] == true
      @users = User.where(:hired_at.lte => date.end_of_month).any_of({left_at: nil}, {:left_at.gte => date.beginning_of_month})
                   .with_role(:employee).order_by(first_name: :asc)
      @users = @users.where(show_in_load_calendar: true)
    else
      @users = User.current_employee
    end

    @users = @users.by_manager(options['current_user_id']) if options['team'].eql?('My Team')


    if options['project_category'] != 'Any category'
      @users = @users.by_project_category(options['project_category'], options['date'])
    end

    if options['company_division'] != 'Any division'
      @users = @users.where(company_division: options['company_division'])
    end

    if options['community'] != 'Any community'
      @users = @users.where(community: options['community'])
    end

    if options['position'] != 'Any position'
      @users = @users.where(position: options['position'])
    end

    case options[:tech]

    when 'Developers'
      @users = @users.developers
    when 'Production'
      @users = @users.production_masters
    when -> (n) { ['Any skills'].exclude?(n) }
      @users = @users.current_employee.where('skills.name' => options[:tech])
    end

    @users = @users.full_search(options) if options[:search_query].present?

    in_load_ranges = -> (n) {n.in?(Load::RANGES.keys)}

    case options[:load_status]
    when in_load_ranges
      @users = @users.employee_with_certain_load(options[:load_status],date)
    when 'Free'
      @users = @users.free_now_employee(date)
    when 'Free Soon'
      @users = @users.free_soon_employee(date)
    when 'Vacations'
      @users = @users.unavailable_employee(date)
    when 'Selfdev'
      @users = @users.selfdev_employee(date)
    end

    case options[:sort_name]
    when 'ascending'
      @users = @users.sort_by{|user| user.full_name}
    when 'descending'
      @users = @users.sort_by{|user| user.full_name}.reverse
    else
      @users
    end
    @users
  end

  def self.get_divisions
    DIVISION_STRUCTURE.map{|org| org[:division]}.flatten
  end

  def self.get_communities
    COMMUNITY_STRUCTURE.map{|org| org[:community]}.flatten
  end

  def self.community_positions(community)
    COMMUNITY_STRUCTURE.detect { |org| org[:community].eql?(community) }&.dig(:positions)
  end

  def self.get_positions
    COMMUNITY_STRUCTURE.map{|org| org[:positions]}.flatten
  end

  def self.role_positions
    positions = COMMUNITY_STRUCTURE.map { |el| el[:positions] }.flatten
    (positions << 'Technical Leader').sort
  end

  def get_people_partner
    self.people_partner if self.people_partner.in?(User.people_partners)
  end

  def get_hiring_manager
    attributes = COMMUNITIES_HIRING_MANAGERS.select do |attribute|
      attribute[:communities].include?(self.community)
    end
    if attributes.present?
      hiring_manager_position = attributes.first[:position]
      User.where(position: hiring_manager_position).first
    end
  end

  def self.people_partners
    User.current_employee.where(:position.in => ['People Partner', 'Head of People Operations'])
  end

  def self.people_partners_names
    self.people_partners.map{|people_partner| people_partner.full_name}
  end

  def is_people_partner?
    has_role? :people_partner
  end

  def is_head_of_people_operations?
    position.eql? 'Head of People Operations'
  end

  def self.selfdev_employee(date)
    self.current_employee_for_projects.select do |u|
      u.load_level(date, date.day) < 100
    end
  end

  def self.by_manager(manager_id)
    projects = Project.where(manager: manager_id).in(status: ['Active', 'Coming Soon', 'Support'])
    user_ids = Load.in(project: projects.map(&:id)).select { |load| (load.get_from_date..load.get_to_date).cover?(Date.today) }&.pluck(:employee).uniq
    self.in(id: user_ids).order_by(first_name: :asc)
  end

  def self.by_teammate(user, sort_order)
    projects = user.current_projects
    loads = Load.in(project: projects.map(&:id)).select { |load| (load.get_from_date..load.get_to_date).cover?(Date.today) }
    users = loads.map(&:employee).uniq.sort_by { |user| user.full_name }.compact
    case sort_order
    when 'ascending'
      users
    when 'descending'
      users.reverse
    else
      users.insert(0, users.delete(user))
    end
  end

  def new_user(first_name, last_name, moc_email, password = '123456789')
    User.create(first_name: first_name, last_name: last_name, moc_email: moc_email, password: password)
  end

  def self.by_project_category(project_category, date)
    projects = Project.where(category: project_category).in(status: ['Active', 'Coming Soon', 'Support', 'Pause'])
    user_ids = Load.in(project: projects&.pluck(:id)).includes(:project).select { |load| load.actual_for_month?(date) }&.pluck(:employee)&.uniq
    self.in(id: user_ids).order_by(first_name: :asc)
  end

  def self.active_managers
    managers = Project.in(status: %w[Active Support]).distinct(:manager)
    User.in(id: managers).current
  end

  # def as_json(*args)
  #   res = super
  #
  #   # convert BSON::ObjectId to string
  #   res['id'] = res['id'].to_s
  #   res['text'] = res.delete('full_name')
  #   res
  # end

  def self.full_search(params)
    param = params[:search_query]
    if !param.empty?
      return category_search(params) if params[:search_in] && params[:search_in] != 'all'

      any_of.full_text_search(param, screening: true, match: :all)
       # result.candidates#
    else
      self
    end
  end

  def self.current_employee_with_children
    self.current_employee.select do |u|
      u.relationship.try(:amount_of_children)
    end
  end

  def dismissed?
    working_status.eql?('Ex Master')
  end

  def get_participated_sessions
    session_ids = self.apr_user_sessions.closed.pluck(:apr_session_id)
    sessions = Apr::Session.where(:id.in => session_ids.uniq)
    sessions.select{|session| session if session.is_valid?}.sort_by { |session | session.from  }.reverse!
  end

  def get_subordinates_sessions
    session_ids = self.apr_evaluator_feedbacks.map do |feedback|
      user_session = feedback.apr_user_session
      user_session.apr_session&.id  if user_session.present?
    end
    sessions = Apr::Session.where(:id.in => session_ids.uniq)
    sessions.select{|session| session if session.is_valid?}.sort_by { |session | session.from  }.reverse!
  end

  def resume_file
    [self.first_name, self.last_name].compact.reject(&:empty?).join('_').delete(' ')
  end

  def update_relationship(relationship_params)
    r = Relationship.find_or_initialize_by(user: self)
    r.update_attributes(relationship_params)
  end

  #### check uniq methods !!!
  def self.get_with_name(full_name)
    full_name = full_name.split(',')
    User.where(first_name: full_name[1], last_name: full_name[0])
  end

  def self.get_with_email(email)
    User.where(email: email.downcase)
  end

  def self.developers
    where('skills.name' => { '$in' => DEV_TECH })
  end

  def self.production_masters
    where('skills.name' => { '$in' => (DEV_TECH + ['QA', 'Designer']) })
  end

  def self.get_with_type(queue, type)
    if type == 'name'
      self.get_with_name(queue)
    elsif type == 'email'
      self.get_with_email(queue)
    else
      []
    end
  end

  def banks
    self.bank_accounts.pluck(:bank)
  end

  def change_left_status
    self.user_status = 'left' unless self.left_at.nil?
  end

  def add_to_interviewers!
    unless self.is_interviewer?
      self.add_role :interviewer
      # self.send_reset_password_instructions
    end
  end

  def questionnaire_answered?
    self.candidate_questionnaire && self.candidate_questionnaire.questionnaire_status == 'finished'
  end

  def managers_today
    managers = []
    today = Date.today
    self.loads.each do |load|
      if ((load.get_from_date..load.get_to_date).cover?(today) && (load.project.status != 'Finished'))
        managers << load.project.manager.moc_email unless load.project.nil?
      end
    end
    managers.uniq
  end

  def avatar_url
    ActionController::Base.helpers.image_url(self.photo.path(:original).present? ? self.photo.url(:original) : 'user_icon_placeholder@2x.png')
  end

  def vacation_days
    # (self.vacation_days_initial - self.vacation_days_used) - self.next_year_vacation_days_used
    vacation_days_past_year + remaining_vacation_days_current_year
  end

  def get_vacation_days_per_year
    if self.vacation_days_per_year.present?
      self.vacation_days_per_year
    elsif self.country.present?
      self.country.vacation_days_per_year
    else
      0.0
    end
  end

  def vacation_days_for_year(year)
    return 0 unless self.country.present?

    # additional_vacation_days = self.additional_vacations.where(:created_at => (Date.new(year)..Date.new(year).end_of_year)).sum(:days)
    additional_vacation_days = count_additional_vacations(year)
    self.vacation_days_per_year.to_f + additional_vacation_days
  end

  def remaining_vac_days_for_year(year)
    vacation_hash = annual_vacation_balance.detect{|obj| obj.keys.first.eql?(year.to_s)}
    total_days = vacation_hash.present? ? vacation_hash[year.to_s] : nil
    if total_days.blank?
      if hired_at.present? && self.left_at.blank?
        set_social_days(year)
        return annual_vacation_balance.detect{|obj| obj.keys.first.eql?(year.to_s)}.blank? ? 0.0 : annual_vacation_balance.detect{|obj| obj.keys.first.eql?(year.to_s)}.values.first
      else
        return 0.0
      end
    else
      total_days
    end
  end

  #old methods >>>>>>
  def vacation_days_current_year_old
    days = [self.vacation_days_old - (vacation_days_past_year_old + next_year_vacation_days_used), vacation_days_for_year(Date.today.year)].min
    [days, 0.0].max
  end

  def vacation_days_past_year_old
    self.previous_year_vacation_days_remaining > 0 ? self.previous_year_vacation_days_remaining : [self.vacation_days_old - vacation_days_for_year(Date.today.year), 0].max
  end

  def next_year_vacation_days_remaining_old
     self.get_vacation_days_per_year - next_year_vacation_days_used
  end

  def earned_vacation_days_old
    total_vac_days_earned = (daily_amount_of_vacation_days_to_accumulate * number_of_working_days_achieved).round_to_half
    vacation_days_taken = self.vacation_days_used < 0 ? 0.0 : self.vacation_days_used
    initial_previous_year_vac = [(self.vacation_days_old - vacation_days_for_year(Date.today.year)) + vacation_days_taken, 0].max
    [(initial_previous_year_vac + (total_vac_days_earned - vacation_days_taken)), 0.0].max
  end

  def vacation_days_old
    (self.vacation_days_initial - self.vacation_days_used) - self.next_year_vacation_days_used
  end

  def vacation_days_current_year
    [self.vacation_days_old - [vacation_days_past_year, next_year_vacation_days_used].compact.sum, vacation_days_for_year(Date.today.year)].min
  end
  #<<<<< old methods

  # new methods >>>>>>
  def vac_days_used(year, category = 'vacation')
    year_start = Date.new(year).beginning_of_year
    year_end = Date.new(year).end_of_year
    case category
    when 'vacation'
      vacations = self.vacations.actual_vacations
      vacations.where(from: (year_start..year_end)).merge(vacations.where(to: (year_start..year_end))) |
        self.vacations.where({category: 'days-off', :created_at.lte => year_start, from: (year_start..year_end), explicit: false})
    when 'sick'
      sick_days = self.vacations.sick_days
      sick_days.where(from: (year_start..year_end)).merge(sick_days.where(to: (year_start..year_end)))
    when 'unpaid'
      year_start_date_for_master = self.resumed_at.present? ? self.resumed_at : self.hired_at
      range = year_start_date_for_master.present? && year_start_date_for_master.year.eql?(year) ? year_start_date_for_master..Date.new(year).end_of_year : Date.new(year)..Date.new(year).end_of_year
      year_start = year_start.year.eql?(year_start_date_for_master.year) ? year_start_date_for_master : year_start
      explicit_unpaid_leaves =  self.vacations.off_days.explicit.not_rejected
      unpaid_leave = self.vacations.off_days.not_rejected.where(explicit: false)
      actual = unpaid_leave.where(created_at: range) - unpaid_leave.where(:created_at.lte => year_start , from: range, sick_leave_unpaid: false)
      explicit = explicit_unpaid_leaves.where(from: range)
      actual + explicit
    else
      return nil
    end
  end

  def get_initial_sick_days(year = nil)
    return 0.0 unless self.hired_at.present?
    year_start_date_for_master = self.resumed_at.present? ? self.resumed_at : self.hired_at
    yearly_sick_days = self.sick_days_per_year.present? ? self.sick_days_per_year : self.country.sick_days_per_year
    if year.present?
      year_start_date_for_master = year.eql?(year_start_date_for_master.year) ? year_start_date_for_master : Date.new(year)
    else
      year_start_date_for_master
    end
    if year_start_date_for_master.year >= Date.today.year
      period_start = year_start_date_for_master.day < 11 ? year_start_date_for_master.at_beginning_of_month : year_start_date_for_master.at_beginning_of_month.next_month
      period_start < year_start_date_for_master.at_end_of_year ? ((13 - period_start.month)*yearly_sick_days/12).round_to_half : 0.0
    else
      self.country.present? ? self.country.sick_days_per_year : 0.0
    end
  end

  def count_vacation_days_used(year, category = 'vacation')
    category.eql?('unpaid') ? vac_days_used(year, category).map{|vac| vac.count_days}.sum :
      vac_days_used(year, category).map{|vac| vac.count_days(year)}.sum
  end

  def sick_days_remaining(year = Date.today.year)
    return 0.0 if year < Date.today.year
    [get_initial_sick_days(year) - count_vacation_days_used(year, 'sick').to_f, 0.0].max
  end

  def count_unpaid_leave(year)
    return 0.0 if self.left_at.present?
    count_vacation_days_used(year, 'unpaid').to_f
  end

  def get_previous_year_remaining(year)
    current_year = Date.today.year
    if year.eql?(current_year)
      [vacation_days_past_year, 0.0].max
    elsif year.eql?(current_year - 1)
      0.0
    elsif year.eql?(current_year + 1)
      [remaining_vacation_days_current_year, 0.0].max
    else
      (current_year - year) >= 2 ? 0.0 : get_vacation_days_per_year
    end
  end

  def total_vacation_days_achieved(date)
    (daily_amount_of_vacation_days_to_accumulate(date) * number_of_working_days_achieved(date)).round_to_half
  end

  def count_additional_vacations(year)
    return 0.0 if self.left_at.present?
    additional_vacations = get_additional_vacations(year)
    additional_vacations.blank? ? 0.0 : additional_vacations.sum(:days)
  end

  def get_additional_vacations(year)
    return [] if self.left_at.present?
    year_start_date_for_master = self.resumed_at.present? ? self.resumed_at : self.hired_at
    range = year_start_date_for_master.present? &&  year_start_date_for_master.year.eql?(year) ? year_start_date_for_master..Date.new(year).end_of_year : Date.new(year)..Date.new(year).end_of_year
    self.additional_vacations.where(:created_at => range)
  end
  # <<<<< new methods

  def remaining_vacation_days_current_year
    year = Date.today.year
    [remaining_vac_days_for_year(year) + count_additional_vacations(year), 0.0].max
  end

  def vacation_days_past_year
    year = Date.today.year - 1
    year_start_date_for_master = self.resumed_at.present? ? self.resumed_at : self.hired_at
    return 0.0 if year_start_date_for_master.present? && year_start_date_for_master&.year >= Date.today.year
    [remaining_vac_days_for_year(year) + count_additional_vacations(year), 0.0].max
    # self.previous_year_vacation_days_remaining > 0 ? self.previous_year_vacation_days_remaining : [self.vacation_days - vacation_days_for_year(Date.today.year), 0].max
  end

  def next_year_vacation_days_remaining
    # return 0.0 unless self.country.present?
    # self.country.vacation_days_per_year - next_year_vacation_days_used
    year = Date.today.year + 1
    remaining_vac_days_for_year(year)
  end

  def next_year_vac_days_used(year = Date.today.year)
    count_vacation_days_used(year + 1)
  end

  def next_year_vacation_days_remaining_future_master
    self.future_master_vacation_days_initial - self.next_year_vacation_days_used
  end

  def earned_vacation_days(date = Date.today)
    year = date.year
    agreement_signed_date = self.resumed_at.present? ? self.resumed_at : self.hired_at

    previous_year_vac = get_previous_year_remaining(year)
    subtracted_days = (vacation_days_per_year - remaining_vac_days_for_year(year))
    if previous_year_vac.positive? && year < Date.today.year + 1
      initial_difference = next_year_vac_days_used(year)
    else
      initial_difference = subtracted_days
        # agreement_signed_date.year.eql?(year) ? subtracted_days : next_year_vac_days_used + count_vacation_days_used(year)
    end
    (previous_year_vac + total_vacation_days_achieved(date) + count_additional_vacations(year)) - initial_difference.to_f.round_to_half
  end

  def number_of_working_days(start_date, end_date)
    total_working_days = 0
    (start_date..end_date).each{|day| total_working_days += 1 unless self.non_working_day?(day)}
    total_working_days
  end

  def number_of_working_days_achieved(chosen_date = Date.today)
    agreement_signed_date = self.resumed_at.present? ? self.resumed_at : self.hired_at
    year_start = chosen_date.beginning_of_year

    return 0 if agreement_signed_date.blank? || agreement_signed_date&.year > chosen_date.year
    # start_date = agreement_signed_date&.year == chosen_date.year ? agreement_signed_date : chosen_date.beginning_of_year
    # non_working_days = start_date.eql?(year_start) ? 0 : number_of_working_days(year_start, start_date - 1)
    number_of_working_days(year_start, chosen_date)
  end

  def daily_amount_of_vacation_days_to_accumulate(chosen_date = Date.today)
    year_start = chosen_date.beginning_of_year
    year_end = chosen_date.end_of_year
    # agreement_signed_date = self.resumed_at.present? ? self.resumed_at : self.hired_at
    # start_date = agreement_signed_date&.year == chosen_date.year ? agreement_signed_date : chosen_date.beginning_of_year
    self.vacation_days_per_year.to_f/self.number_of_working_days(year_start, year_end)
  end

  def non_working_day?(day)
    (day.saturday? || day.sunday?) || Holiday.where(date: day, country: self.country).any?
  end

  def name_of_country
    self.country&.name
  end

  def name_of_office
    self.office&.name
  end

  def add_to_managers!
    unless self.is_manager?
      self.add_role :manager
      # self.send_reset_password_instructions
    end
  end

  def add_to_hr!
    unless self.is_hr_manager?
      self.add_role :hr_manager
    end
  end

  def add_to_lead!
    unless self.is_lead?
      self.add_role :lead
    end
  end

  def add_to_admin!
    unless self.is_admin?
      self.add_role :admin
    end
  end

  def add_to_hr_lead!
    add_role :hr_lead unless is_hr_lead?
  end

  def add_to_people_partner!
    add_role :people_partner unless is_people_partner?
  end

  def has_user_status?
    self.user_status and self.user_status != 'none'
  end

  def has_people_partner?
    self.get_people_partner.present?
  end

  def has_company_division?
    self.company_division and self.company_division != 'none'
  end

  def has_community?
    self.community and self.community != 'none'
  end

  def has_position?
    self.position and self.position != 'none'
  end

  def has_additional_position?
    additional_position && additional_position != 'none'
  end

  def has_english_level?
    self.english_level and self.english_level != 'none'
  end

  def has_any_contact?
    (self.email and !self.email.blank?)
  end

  def hiring?
    self.user_status == 'hiring'
  end

  def reset_interviewed_at!
    self.update_attribute('interviewed_at', nil)
  end

  def full_name
    ActionController::Base.helpers.sanitize [self.first_name, self.last_name].compact.reject(&:empty?).join(' ')
  end

  def is_admin?
    self.has_role? :admin
  end

  def is_candidate?
    #self.has_role? :candidate
    self.hired_at.nil? and self.user_status != 'agreement signed' and self.left_at.nil?
  end

  def is_ceo?
    self.has_role? :ceo
  end

  def is_client?
    self.has_role? :client
  end

  def is_office_manager?
    self.has_role? :office_manager
  end

  def changes_date_only?
    !(company_division_changed? || community_changed? || position_changed?) && changes_date_changed?
  end

  def position_changes_only?
    (company_division_changed? || community_changed? || position_changed?) && !changes_date_changed?
  end

  def lp_specific_positions?(projects)
    position.in?(Vacation::APPROVED_BY_LP_GENERAL_MANAGER) && Project.lp_projects_present?(projects)
  end

  def set_office
    office = Office.where(name: city).first
    self.update_attributes({office: office}) if office.present?
  end

  def set_social_days_per_year
    vacation_days_per_year = self.country.present? ? self.country.vacation_days_per_year : 0.0
    sick_days_per_year = self.country.present? ? self.country.sick_days_per_year : 0.0
    self.update_attributes({vacation_days_per_year: vacation_days_per_year, sick_days_per_year: sick_days_per_year})
  end

  def set_social_days(target_year = nil)
    return if self.hired_at.blank? && target_year.nil?

    year_start_date_for_master = self.resumed_at.present? ? self.resumed_at : self.hired_at
    year_end_date = year_start_date_for_master.end_of_year
    year = year_start_date_for_master.year

    period_start = year_start_date_for_master.day < 11 ? year_start_date_for_master.at_beginning_of_month : year_start_date_for_master.at_beginning_of_month.next_month
    full_working_days = number_of_working_days(period_start, year_end_date)
    vacation_days_initial = (full_working_days * daily_amount_of_vacation_days_to_accumulate).round_to_half
    sick_days_initial = period_start < year_start_date_for_master.at_end_of_year ? ((13 - period_start.month)*self.sick_days_per_year/12).round_to_half : 0
    if target_year.present?
      return unless annual_vacation_balance.detect{|obj| obj.keys.first.eql?(target_year.to_s)}.nil?
      if target_year.eql?(year)
        vac_days = vacation_days_initial
      else
        vac_days = target_year < Date.today.year ? 0.0 : vacation_days_for_year(target_year)
      end
      vacation_balance = annual_vacation_balance
      vacation_balance += [{target_year.to_s => vac_days}]
      self.update_attributes(annual_vacation_balance: vacation_balance)
      return vac_days
    end
    if year.eql?(Date.today.year + 1)
      next_year_vac_info = {year.to_s => vacation_days_initial}
      current_vac_info = {(year - 1).to_s => 0.0}

      if annual_vacation_balance.detect{|obj| obj.keys.first.eql?(year.to_s)}.nil?
        vacation_balance = annual_vacation_balance
        vacation_balance += [current_vac_info, next_year_vac_info]
        self.update_attributes(annual_vacation_balance: vacation_balance)
      end
      # self.update_attributes({future_master_vacation_days_initial: vacation_days_initial})
      # self.update_attributes({future_master_sick_days: sick_days_initial})
    else
      current_vac_info = {year.to_s => vacation_days_initial}
      next_year_vac_info = {(year + 1).to_s => get_vacation_days_per_year}
      if annual_vacation_balance.detect{|obj| obj.keys.first.eql?(year.to_s)}.nil?
        vacation_balance = annual_vacation_balance
        vacation_balance += [current_vac_info, next_year_vac_info]
        self.update_attributes(annual_vacation_balance: vacation_balance)
      end
      # self.update_attributes({vacation_days_initial: vacation_days_initial})
      # self.update_attributes({sick_days: sick_days_initial})
      # self.vacations.where(category: 'sick').each { |v| v.process_days} unless resumed_at.present?
    end
  end

  def clear_social_days
    # self.update_attributes(vacation_days_initial: 0.0, sick_days: 0.0, future_master_vacation_days_initial: 0.0,
    #                        vacation_days_used: 0.0, previous_year_vacation_days_remaining: 0.0,
    #                        future_master_sick_days: 0.0, days_off: 0.0)
    self.update_attributes(annual_vacation_balance: [{Date.today.year - 1 => 0.0}])
  end

  def set_accounting_data
    accounting = Acc::AccountingService.new
    contractor = Contractor.new(self.id)
    accounting.init_masters_accounts(contractor)
    accounting.init_master_sourcebook(contractor)
  end

  def set_jira_account_id
    jira_account_id = Utils::JiraLibrary::JiraManager.new(instance: Utils::JiraLibrary::JiraManager::MOCG).get_account_id(self)
    self.update_attribute(:jira_account_id, jira_account_id) if jira_account_id.present?
  end

  def update_relations_keywords
    if (self.previous_changes.keys & %w(first_name last_name)).present?
      self.vacations.each { |el| el.index_keywords! }
      self.pcs.each { |el| el.index_keywords! }
      self.hardwares.each { |el| el.index_keywords! }
    end
  end

  def future_employee?
    return false unless self.hired_at.present?
    self.hired_at.year > Date.today.year
  end

  def change_to_employee!
    Role.remove_user_from_role(:candidate,self)
    unless self.has_role? :employee
      self.add_role(:employee)
      self.tech_to_skill
      self.set_office
      self.set_social_days_per_year
      self.set_social_days
      self.save
    end
  end

  def change_to_candidate!
    Role.remove_user_from_role(:employee,self)
    Role.remove_user_from_role(:interviewer,self)
    Role.remove_user_from_role(:manager,self)
    unless self.has_role? :candidate
      self.skill_to_tech
      self.save
      self.add_role(:candidate)
    end
  end

  def check_trial(trial_param)
    if trial_param == '0' && self.on_trial == true
      self.update_attributes(retrospective_date: Date.today)
      SendHrRetrospectiveNotificationWorker.perform_at(6.months.from_now - 1.week, self.id.to_s)
    end
  end

  def is_left?
    self.left_at != nil
  end

  def is_employee?
    #self.has_role? :employee
    (self.hired_at != nil or self.user_status == 'agreement signed') and self.left_at.nil?

  end

  def is_interviewer?
    #self.has_role? :employee and self.can_interview
    self.has_role? :interviewer
  end
#
  def is_manager?
    #self.has_role? :employee and self.can_interview
    self.has_role? :manager
  end

  def is_head?
    return false unless self.position.present?
    self.position.include?('Head')
  end

  def is_lead?
    self.has_role? :lead
  end

  def is_admin?
    self.has_role? :admin
  end
#
  def is_tech_admin?
    #self.has_role? :employee and self.can_interview
    self.has_role? :manager
  end
#
  def is_hr_manager?
    self.has_role?(:hr_manager) || self.has_role?(:hr_test)
  end

  def is_hr_lead?
    has_role? :hr_lead
  end

  def is_designer?
    designer_positions = ['Graphic Designer', 'Motion Designer', 'UI/UX Designer']
    self.position.in?(designer_positions)
  end

  def is_head_of_marketing?
    position.eql? 'Head of Marketing'
  end

  def is_business_analyst_lead?
    position.eql? 'Business Analyst Lead'
  end

  def is_devops?
    self.position.eql? "DevOps Engineer"
  end

  def is_system_administrator?
    self.position.eql? "Systems Administrator"
  end

  def is_infrastructure_leader?
    position.eql?('Infrastructure Leader')
  end

  def is_lp_project_manager?
    self.lp_projects.present?
  end

  def is_only_lp_pm?
    self.is_lp_project_manager? && self.current_projects.count.eql?(lp_projects.count)
  end

  def has_only_master_role?
    !self.is_manager? && !self.is_hr_manager? && !self.is_admin? && !self.is_office_manager? && !self.is_ceo? &&
      !self.is_lead? && self.not_hr_test? && self.is_employee?
  end

  def lp_projects
    self.current_projects.select{|project| project.category.eql?("LivePerson")}
  end

  def not_hr_test?
    !self.has_role? :hr_test
  end

  def interview_assigned?
    self.interview_status == 'assigned'
  end

  def interview_passed?
    self.interview_status == 'passed'
  end

  def get_questions(limit = 20)
    if self.has_questions?
      # Questionnaire.first.questions.any_in(:id => self.questions.map{|k,_| k})
      Question.all.any_in(:id => self.questions.map{|k,_| k})
    else
      # Questionnaire.first.questions
      Question.all
    end
  end

  def has_questions?
    #self.questions.count > 0
    self.candidate_questionnaire.questions.count > 0
  end

  def questionnaire_sent?
    self.questionnaire_status == 'sent' and self.has_questions?
  end

  def questionnaire_completed?
    (self.questionnaire_status == 'recd' or self.questionnaire_status == 'checked' or self.questionnaire_status == 'received review') and self.has_questions?
  end

  def generate_candidate_url(request)
    "#{request.protocol}#{request.host_with_port}#{pass_questionnaire_user_path(self)}"
  end

  def set_questions(selected_questions = nil)

    CandidateQuestionnaire.set_questions(self, selected_questions)
  end

  def language_method(question)
    "text_#{self.questions.select{|k,_| k == question.id.to_s}.first.last}"
  end

  def get_answer(question)
    answer = self.answers.where(question: question).first()
    answer.text if self.answers.count > 0 and answer
  end
#
  def has_email?
    return self.email.match(/.{1,}@.{1,}/)
  end

  def has_answers_for_all_questions?
    self.answers.not_blank.count == self.questions.count
  end

  def str_tel_number
    ActionController::Base.helpers.sanitize self.tel_number.split(', ').join('<br>') if self.tel_number
  end

  def create_sf_dir
    return if remote_dirname.present? && check_sf_dir
    dirname = "/#{self.full_name.gsub(' ','_')}"
    #//$sf.create_dir(dirname)


    #curl -d  "operation=mkdir" -v  -H 'Authorization: Token 7b79c925cad89d4b5810aefa37428cf030b88be5' -H 'Accept: application/json; charset=utf-8; indent=4' https://seafile.mocintra.com/api2/repos/74056023-a550-4e3e-860e-8ca2086cdec9/dir/?p=/foo

    #//$sf.create_dir("#{dirname}/test_files")

    self.update_attributes(remote_dirname: dirname)
  end

  def check_sf_dir
    #//$sf.download_dir(remote_dirname).scan('/files/').present?
  end

  def str_technologies
    self.skills.map{|skill| skill.name}.join(', ')
  end

  def self.get_interviewers
    User.current_interviewers
  end

  def self.get_managers
    User.with_role(:hr_manager)
  end

  def self.questionnaire_checkers
     User.current_interviewers.collect {|p| [ p.full_name, p.id ] }
  end

  def self.get_candidate_autocomplete(term)
    data = []
    result = []
    data += User.with_role(:candidate).any_of({ :first_name => /#{term}/i }).map{|u| u.full_name}
    data += User.with_role(:candidate).any_of({ :last_name => /#{term}/i }).map{|u| u.full_name}
    data += User.with_role(:candidate).any_of({ :sallary => /#{term}/i }).map{|u| u.full_name}
    data += User.with_role(:candidate).any_of({ :reference => /#{term}/i }).map(&:reference)
    data += User.with_role(:candidate).any_of({ :reference_additional => /#{term}/i }).map(&:reference_additional)
    data += User.with_role(:candidate).any_of({ :email => /#{term}/i }).map(&:email)
    data += User.with_role(:candidate).technologies.select { |t| /#{term}/i =~ t }
    data.uniq.each do |d|
      result += [id: d, value: d]
    end
    result.take(10).to_json
  end

  def self.get_employee_autocomplete(term)
    data = []
    result = []
    data += User.with_role(:employee).any_of({ :first_name => /#{term}/i }).map{|u| u.full_name}
    data += User.with_role(:employee).any_of({ :last_name => /#{term}/i }).map{|u| u.full_name}
    data += User.with_role(:employee).any_of({ :email => /#{term}/i }).map(&:email)
    data.uniq.each do |d|
      result += [id: d, value: d]
    end
    result.take(10).to_json
  end

  def skills_list
    skills.map{|skill| "#{skill.name} - (#{skill.level.present? ? skill.level : 'unknown-lvl' })"}.join("\n")
  end

  def project_list_str
    loads.includes(:project).map{|load| load.project.name if load.project.present?}.uniq
  end

  def project_list(date: nil)
    if date.nil?
      loads.includes(:project).map{|load| load.project if load.project.present? && !load.project.unactive?}.uniq - [nil]
    else
      loads.includes(:project).map{|load| load.project if load.project.present? && !load.project.unactive? && load.actual_for_month?(date)}.uniq - [nil]
    end
  end

  def loads_project_list(date)
    loads.includes(:project).map do |load|
      if load.project.present? && (!load.project.status.in?(%w(Finished Archived)) && load.actual_for_month?(date) ? true :
                                     (load.actual_for_month?(date)))
        if (load.load > 0 || load.load == -1) && load.project.actual_for_date?(date)
          load.project  unless load.project.unactive?
        end
      end
    end.uniq - [nil]
  end

  def managers
    loads.map{|load| load.project.manager.full_name if load.project.present?}.uniq.join(',')
  end

  def project_comments
    loads.map{|load| load.project.comments if load.project.present?}.uniq.join(',')
  end

  def has_unattended_approves?(type = 'vacation')
    case type
    when 'vacation'
      @approves = vacation_approves
    when 'overtime'
      @approves = overtime_approves
    end
    need_to_answer = false
    @approves.each do |approve|
      if  approve.is_approved.nil?
        need_to_answer = true
      end
    end
    need_to_answer
  end

  def unattended_approves(approval_type = 'vacation')
    case approval_type
    when 'vacation'
      vacation_approves.select { |va| va.is_approved.nil? && va.vacation.status.nil? }
    when 'overtime'
      overtime_approves.select { |ov| ov.is_approved.nil? && !(ov.canadian? || ov.overtime.hours < 0.25)}
    end
  end

  def outstanding_feedback_entities_quantity
    count = 0
    current_session = Apr::Session.where(status: Apr::Session::SESSION_STATUSES[:active]).first
    if current_session.present?
      current_user_session = current_session.apr_user_sessions.where(master: self).first
      self_feedback = current_user_session.apr_feedbacks.by_self.first if current_user_session.present?
      self_feedback.completed? ? count +=0  : count += 1 if self_feedback.present? && current_user_session.active?
      count += count_feedback_requests(current_session)
    end
    count += unseen_feedback_results
    count
  end

  def count_feedback_requests(apr_session)
    feedbacks_in_session = Apr::Feedback.by_user_session(apr_session.apr_user_sessions.pluck(:id)).outstanding.valid
    feedbacks_as_peer = feedbacks_in_session.by_peer(self).approved_by_hr_admin
    feedbacks_as_evaluator = feedbacks_in_session.by_evaluator(self)
    feedback_requests = (feedbacks_as_peer | feedbacks_as_evaluator).map do |feedback|
      feedback unless feedback.apr_user_session.closed_or_completed?
    end
    feedback_requests.compact.size
  end

  def unseen_feedback_results
    count = 0
    personal_sessions = self.apr_user_sessions
    if personal_sessions.present?
      personal_sessions.each do |user_session|
        count += 1 if user_session.closed? && !user_session.viewed_personal_report
      end
      count
    else
      count
    end
    feedbacks_as_evaluator = self.apr_evaluator_feedbacks.valid
    user_sessions = feedbacks_as_evaluator.map { |fb| fb.apr_user_session }.uniq.compact
    if user_sessions.present?
      user_sessions.each do |user_session|
        if user_session.apr_session.present?
          count += 1 if user_session.apr_session.is_valid? && (user_session.report_viewers.exclude?(self) && user_session.closed_or_completed?)
        else
          count
        end
      end
      count
    else
      count
    end
  end

  def process_vacation_approves_after_dismissal
    unattended_approves.each do |va|
      if va.vacation.approves.size == 1
        va.update(manager: self.class.default_vacation_approver)
        SendVacationRequestsWorker.perform_async(va.id.to_s) if va.vacation.from >= Date.today
      else
        va.destroy
      end
    end
  end

  def process_overtime_approves_after_dismissal
    unattended_approves('overtime').each do |overtime_approve|
      if overtime_approve.overtime.approves.size == 1
        overtime_approve.update(manager: self.class.default_vacation_manager)
        # SendOvertimeRequestsWorker.perform_async(overtime_approve.id.to_s)
      else
        overtime_approve.destroy
      end
    end
  end

  def planned_time(from, to)
    planned_time = []
    (from.to_date..to.to_date).each do |date|
      day = Holiday.is_holiday?(date, self.country) ? 'holiday' : self.what_day?(date)
      planned = case day
                when 'saturday', 'sunday'
                  next
                when 'holiday', 'vacation', 'sick', 'unpaid leave'
                  0
                when 'half_day', 'half_day_sick'
                  4
                else
                  8
                end
      planned_time << {date: date, planned: planned}
    end

    return planned_time
  end

  def planned_time_for_month(date)
    plan_for_month = self.planned_time(date.beginning_of_month, date.end_of_month)
    return 0 if plan_for_month.blank?
    plan_for_month.map{|s| s[:planned]}.reduce(0, :+)
  end

  def working_days_for_month(date)
    count = 0
    hours_to_days = {8 => 1, 4 => 0.5, 0 => 0}
    plan_for_month = self.planned_time(date.beginning_of_month, date.end_of_month)
    return 0 if plan_for_month.blank?
    plan_for_month.each{|day| count += hours_to_days[day[:planned]]}
    count
  end

  def what_day?(date, day = nil)
    if day.present?
      current_date = Date.new(date.year, date.month, day)
    else
      current_date = date
    end
    if current_date.saturday?
      'saturday'
    elsif current_date.sunday?
      'sunday'
    else
      vac_info = {
        'sick' => 0.0,
        'vacation' => 0.0,
        'unpaid leave' => 0.0
      }
      vacations.each do |vacation|
        if vacation.approved?
          if (vacation.from..vacation.to).cover?(current_date)
            if vacation.category == 'sick'
              if vacation.half_day?
                vac_info['sick'] += 0.5
              else
                return 'sick'
              end
            elsif vacation.category == 'vacation'
              if vacation.half_day?
                vac_info['vacation'] += 0.5
              else
                return 'vacation'
              end
            else
              if vacation.half_day?
                vac_info['unpaid leave'] += 0.5
              else
                return 'unpaid leave'
              end
            end
          end
        end
      end

      if vac_info.values.count(0.5) > 1
        categories = vac_info.select{|type, days| days.eql?(0.5)}.keys
        return "two halves: #{categories[0].to_s}, #{categories[1].to_s}"
      end
      return vac_info['sick'] == 0.5 ? 'half_day_sick' : 'sick' unless vac_info['sick'] == 0.0
      return vac_info['vacation'] == 0.5 ? 'half_day' : 'vacation' unless vac_info['vacation'] == 0.0
      return vac_info['unpaid leave'] == 0.5 ? 'half_day' : 'unpaid leave' unless vac_info['unpaid leave'] == 0.0
      working = 0
      booked = 0
      loads.each do |load|
        next unless (load.get_from_date..load.get_to_date).cover?(current_date)
        next if load.load >= -1 && load.project&.unactive?
        break if (working > 1 && booked > 1)
        if load.load > -1
          working += 1
        elsif
          booked += 1
        end
      end
      if working == 0  && booked > 0
        return 'booked'
      elsif working > 0  && booked > 0
        return 'working,booked'
      else
        return 'working'
      end
        #return ((working == 0  && booked > 0 ) ? 'booked' : 'working')
    end
  end

  def load_level(date, day, detailed = false)
    load_data = [{'billable' => true, 'value' => 0}, {'billable' => false, 'value' => 0}]
    loads.includes(:project).each do |load|
      next unless load.project.present?
      within_individual_range = load.actual_for_month?(date)
      if ((load.get_from_date(refer_to_project_date: true)..load.get_to_date(refer_to_project_date: true)).cover?(
        Date.new(date.year, date.month, day)) && load.load > 0 && within_individual_range)
        load_data << {'billable' => load.billable, 'value' => load.load}
      end
    end
    grouped_load_data = group_data(load_data, ['billable'], ['value'])
    billable_load_value = grouped_load_data.select {|h| h['billable'] == true}.first['value']
    sum_value = grouped_load_data.sum{|data| data['value']}
    total_load = {'total_load' => sum_value}
    if detailed
      if billable_load_value > 0
        grouped_load_data.select { |h| h['billable'] == true }.first.merge(total_load)
      elsif grouped_load_data.select { |h| h['billable'] == false }.first['value'] >= 100
        grouped_load_data.select { |h| h['billable'] == false }.first.merge(total_load)
      else
        grouped_load_data.select { |h| h['billable'] == true }.first.merge(total_load)
      end
    else
      sum_value
    end
  end

  def load_level_for_project(date, day, project)
    user_load_percent = 0

    actual_loads = []
    loads.where(project: project).each do |load|
      if ((load.get_from_date(refer_to_project_date: true)..load.get_to_date(refer_to_project_date: true)).cover?(
        Date.new(date.year, date.month, day)))
        # next if project&.unactive? && load.load > -1
        actual_loads << load
      end
    end
    actual_loads.each do |load|
      next if load.load == -1 && actual_loads.size > 1
      user_load_percent += load.load
    end
    user_load_percent
  end

  def get_working_status
    self.working_status
    # return 'left' if left_at.present?
    #
    # vacations.where(status: 'approved').each do |vacation|
    #   if (vacation.from..vacation.to).cover?(Date.today)
    #     return "on #{vacation.sick? ? 'sick leave' : 'vacation'} till #{(vacation.to + 1.day).strftime("%d.%m.%Y")}"
    #   end
    # end
    # 'working'
  end

  def working_days_number(dates, exclude_weekends_holidays = true)
    working_days = 0.0
    dates.each do |date|
      date = date.to_date
      if exclude_weekends_holidays
        next unless Calendar.working_day?(date, self.country)
      end
      working_day = 1.0
      vacations.approved.each do |vacation|
        if (vacation.from..vacation.to).cover?(date)
          working_day = vacation.half_day ? 0.5 : 0.0
          break
        end
      end
      working_days += working_day
    end
    working_days
  end

  def current_projects
    project_list = []
    loads.includes(:project).each do |load|
      project_list << load.project if load.project.present? && !load.project.try('unactive?') && (
        load.get_from_date(refer_to_project_date: true)..load.get_to_date(refer_to_project_date: true)).cover?(Date.today)
    end
    project_list.uniq
  end

  def current_projects_list(format = 'inline')
    current_projects_list = current_projects&.map(&:name)
    return '' unless current_projects_list.present?
    separator = format == 'inline' ? ', ' : "\n"
    current_projects_list.join(separator)
  end

  def current_projects_for_graylog
    project_list = []
    loads.each do |load|
      project_list << load.project.try!(:graylog_names) if (load.Date.today..load.get_to_date).cover?(Date.today) && !load.project.try('unactive?')
    end
    project_list.compact.join(",").gsub(/\s+/, '').split(',')
  end

  def current_projects_for_errbit
    project_list = {}
    loads.each do |load|
      next unless load.project.errbit_keys.presence && (load.get_from_date..load.get_to_date).cover?(Date.today) && !load.project.try('unactive?')
      project_list[load.project.name] = load.project.errbit_keys.split(',')
    end
    project_list
  end

  def active_and_support_projects(both: false)
    current_project =self.current_projects
    if current_project.present?
      sorted_projects = current_project.sort_by{|project| project.get_from_date}
      active_projects = both ? sorted_projects.select { |project| project.status.eql?("Active") || project.status.eql?("Support") } :
                          sorted_projects.select { |project| project.status.eql?("Active") }
      active_projects.present? ? active_projects : (sorted_projects.select { |project| project.status.eql?("Support")}) unless both
      active_projects
    end
  end

  def first_free_day_in_month(from)
    to = from + 1.month
    (from..to).each do |date|
      current_load_level = self.load_level(date, date.day)
      if (current_load_level == 0 || current_load_level == -1) && !date.saturday? && !date.sunday?
        return date
      end
    end
    return
  end

  def self.employee_with_certain_load(load, date)
    range = Load::RANGES[load]
    User.current_employee_for_projects.select do |u|
      current_load_level = u.load_level(date, date.day)
      range === current_load_level
    end
  end

  def self.free_now_employee(date)
    User.current_employee_for_projects.select do |u|
      current_load_level = u.load_level(date, date.day)
      current_load_level == 0 || current_load_level == -1
    end
  end

  def self.free_soon_employee(date)
    users = User.current_employee_for_projects.select do |u|
      !u.first_free_day_in_month(date).nil?
    end
    # users.to_a.sort_by(&:first_free_day_in_month(date))
    users.to_a.sort_by {|u| u.first_free_day_in_month(Date.today)}
  end

  def self.moc_emails
    current_employee.distinct(:moc_email).uniq.reject(&:empty?)
  end

  def self.moc_emails_with_rights
    current_employee.map{|u| next unless u.moc_email.present?; [u.moc_email, u.is_ceo?||
        u.is_office_manager? ||
        u.is_hr_manager? ||
        u.is_manager? ||
        u.is_interviewer? ]}.compact.uniq
  end

  def self.unavailable_employee(date)
    if date.saturday? || date.sunday?
      if date == date.beginning_of_month
        date += 1.days until date.monday?
      elsif date == date.end_of_month
        date -= 1.days until date.friday?
      end
    end

    self.all.to_a.select do |u|
      u.what_day?(date, date.day) == 'vacation'
    end
  end

  def skill_to_tech
    return unless self.skills.present?
    self.technologies = self.skills.map{|skill| skill.name}
  end

  def remove_loads
    self.loads.destroy_all
  end

  def finish_loads(end_date)
    self.loads.or({to: nil}, {:to.gt => end_date}).update_all(to: end_date)
  end

  def unassign_projects
    self.projects.where(:status.nin => %w(Archived Finished)).update_all({manager: nil})
  end

  def tech_to_skill
      self.skills.destroy_all if skills.present?
      if technologies.present?
        self.technologies.each{|tech|
          self.skills.create(name: tech) unless self.skills.where(name: tech).present?
        }
      end
  end

  def skills_names
    skills.map{|skill| skill.name}.uniq
  end

  def remove_photo
    self.photo = nil
    self.save
  end

  def is_filled_legal_info
    !self.hardware_info.nil? && !self.passport_info.nil?
  end

  def has_role?(*args)
    Rails.cache.fetch([cache_key, 'has_role?', *args]) { super }
  end

  def self.export_legal_data_in_csv
    masters = User.current_employee
    CSV.open("legal.csv", "wb") do |csv|
      masters.each do |master|
      passport_info = master.passport_info
      hardware_info = Pc.formatted(master)
      legal_info = (passport_info.present? ? passport_info.formatted : (PassportInfo.empty_formatted)) + "\t\t\t" + hardware_info
     # csv <<
      csv << [master.full_name] +legal_info.split("\t")
      # ...
      end
    end
  end

  def will_save_change_to_email?
    false
  end

  private

  def questions_with_language(questions_ids)
    result = Hash.new
    if questions_ids.present?
      questions_ids.each do |questions_id|
        case self.english_level
          when 'none' then result = result.merge({questions_id.to_s => 'ua'})
          when 'low' then result = result.merge({questions_id.to_s => rand() <= 0.2 ? 'en' : 'ua'})
          when 'intermediate' then result = result.merge({questions_id.to_s => rand() <= 0.5 ? 'en' : 'ua'})
          when 'high' then result = result.merge({questions_id.to_s => rand() <= 0.8 ? 'en' : 'ua'})
        end
      end
    end
    result
  end

end
