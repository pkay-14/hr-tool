class Vacation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Mongoid::History::Trackable
  include Mongoid::Paranoia

  field :from, type: Date
  field :to, type: Date
  field :category, type: String
  field :status, type: String
  field :half_day, type: Boolean, default: false
  field :sick_leave_unpaid, type: Boolean, default: false
  field :explicit, type: Boolean, default: false
  field :notes, type: String

  belongs_to :employee , class_name: 'User', touch: true
  has_many :approves, class_name: 'VacationApprove', dependent: :destroy

  index({
          employee_id: 1,
          status: 1,
          deleted_at: 1,
          from: 1,
          to: 1
        }
  )

  track_history   on: [:fields],       # track title and body fields only, default is :all
                  modifier_field: :modifier, # adds "belongs_to :modifier" to track who made the change, default is :modifier
                  modifier_field_inverse_of: :nil, # adds an ":inverse_of" option to the "belongs_to :modifier" relation, default is not set
                  version_field: :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  track_create: true,    # track document creation, default is false
                  track_update: true,     # track document updates, default is true
                  track_destroy: true     # track document destruction, default is false


  search_in employee: [:first_name, :last_name]

  scope :by_date, -> { order_by(from: :desc, _id: :desc) }
  scope :approved, -> { where(status: 'approved') }
  scope :not_rejected, -> {not_in(status: 'rejected') }
  scope :sick_days, -> { where(category: 'sick') }
  scope :off_days, -> { where(category: 'days-off') }
  scope :actual_vacations, -> { where(category: 'vacation') }
  scope :explicit, -> { where(explicit: true) }

  before_destroy -> { process_days(true, false, self.to.year > Date.today.year ) unless rejected?}

  paginates_per 10

  EXEMPT_POSITIONS = ['Product Manager', 'Scrum Master', 'LP General Manager', 'Project Manager']
  APPROVED_BY_LP_GENERAL_MANAGER = ['Atlassian Administrator', 'Database Engineer', 'Data Analyst'].freeze

  VACATION_CATEGORIES = {
    'days-off' => 'Unpaid leave',
    'sick' => 'Sick leave',
    'vacation' => 'Vacation'
  }.freeze

  def approve!
    self.update_attributes(status: 'approved')
  end

  def reject!
    self.process_days(revert: true)
    self.update_attributes(status: 'rejected')
  end

  def approved?
    status == 'approved'
  end

  def rejected?
    status == 'rejected'
  end

  def approved_by?(user)
    approve = approves.where(manager: user).last
    if approve
      approve.is_approved
    else
      false
    end
  end

  def sick?
    category == 'sick'
  end

  def vacation?
    category == 'vacation'
  end

  def in_status_str
    case category
      when 'vacation'
        'відпочиватиме'
      when 'sick'
        'буде відсутній(ня) з причини хвороби'
      when 'days-off'
        'відпочиватиме'
    end
  end

  def status_str
    case category
      when 'vacation'
        'відпочинку'
      when 'sick'
        'відпочинку з приводу хвороби'
      when 'days-off'
        'відпочинку'
    end
  end

  def day_off?
    category == 'days-off'
  end

  def people_partner
    self.employee.get_people_partner
  end

  def head_positions
    User.get_positions.select{|pos| pos.include?('Head')}
  end

  def head_of_community(community)
    head_position = 'none'
    positions = User::COMMUNITY_STRUCTURE.map{ |obj| obj[:positions] if obj[:community].eql?(community)}.flatten.compact
    positions.each do |position|
      head_position = position if position.include?('Head')
    end
    head_position
  end

  def head_position_communities
    User::COMMUNITY_STRUCTURE.select{|x| x[:positions].join(' ').match(/Head/)}.map{|block| block[:community]}.flatten
  end

  def approvers
    first_level_approvers = []
    second_level_approvers = [people_partner]
    employee = self.employee
    valid_projects = employee.active_and_support_projects(both: true)
    first_level_approvers << User.where(position: 'LP General Manager').first if employee.lp_specific_positions?(valid_projects)
    case employee.company_division
    when 'Delivery'
      if employee.position.in?(EXEMPT_POSITIONS)
        first_level_approvers << User.where(position: 'Delivery Operations Manager').first
        first_level_approvers << User.where(position: 'LP General Manager').first if Project.lp_projects_present?(valid_projects) &&
                                                                                     !employee.position.eql?('LP General Manager')
      elsif employee.position.eql?('DevOps Engineer')
        first_level_approvers << User.where(position: 'Infrastructure Leader').first
      elsif employee.position.eql?('Infrastructure Leader')
        first_level_approvers << employee.get_hiring_manager
      else
        if valid_projects.present?
          valid_projects.each do |project|
            next if employee.lp_specific_positions?(valid_projects) && project.category.eql?('LivePerson')

            first_level_approvers << project.manager unless project.manager.eql?(employee)
          end
        end
      end
    when 'Business Operations'
      if employee.community.in?(head_position_communities)
        unless employee.position.in?(head_positions)
          approver = User.where(position: head_of_community(employee.community))
          first_level_approvers << approver.first if approver.present?
        else
          first_level_approvers << employee.get_hiring_manager
        end
      elsif employee.position.in?(User.community_positions('Infrastructure Administration'))
        first_level_approvers << User.where(position: 'Infrastructure Leader').first unless employee.position.eql?('Atlassian Administrator') &&
                                                                                            Project.only_lp_projects?(valid_projects)
      elsif employee.community.eql?('Finance') || employee.position.in?(User.community_positions('Security'))
        first_level_approvers << employee.get_hiring_manager
      elsif employee.community.eql?('Learning and Development')
        first_level_approvers << User.where(position: 'Head of People Operations').first
        second_level_approvers.pop
      else
        first_level_approvers << people_partner
        second_level_approvers.pop
      end
    else
      first_level_approvers << people_partner
      second_level_approvers.pop
    end
    if first_level_approvers.compact.blank?
      first_level_approvers << people_partner
      second_level_approvers.pop
    end
    {
      first_level: first_level_approvers.uniq.compact,
      second_level: second_level_approvers - first_level_approvers
    }
  end

  def notification_receivers
    receivers = approvers[:first_level]
    receivers << User.current.community_leads(employee.community).excludes(id: employee).to_a
    receivers << User.active_managers.to_a if employee.position.in?(['DevOps Engineer', 'Systems Administrator'])
    receivers << employee.get_hiring_manager

    # if employee.position.eql?("Quality Assurance Engineer")
    #   User.where(:moc_email.in => %w(irina.nikulina@masterofcode.com)).each {|master| receivers << master}
    # end
    # if employee.position.eql?("Conversation Designer")
    #   receivers << User.where(moc_email: 'amanda.stevens@masterofcode.com').first
    # end
    # if employee.moc_email.in?(User.lp_project_managers.pluck(:moc_email))
    #   receivers << User.where(moc_email: 'irina.nikulina@masterofcode.com').first
    # end
    # if employee.position.in?(['DevOps Engineer', 'Systems Administrator'])
    #   User.current_employee.where(position: 'Project Manager').each {|master| receivers << master}
    # end

    receivers.flatten.compact.uniq
  end

  def request_notification_receivers
    receivers = []
    receivers << User.where(moc_email: 'tatiana.bened@masterofcode.com').first if employee.country.name.eql?('USA')
    receivers << employee.get_hiring_manager unless from <= 2.days.from_now && category.eql?('sick')

    receivers.compact.uniq
  end

  def not_approved_managers
    approves.where(:'is_approved'.ne => true).includes(:manager).map {|approve| approve.manager&.full_name if approve.manager.present? }
  end

  def check_is_approved(second_level = false)
    return false if approves.blank?
    first_level_approves = approves.where(second_level_approver: false)
    return true if self.approved?
    if second_level
      is_approved = true
    else
      is_approved = first_level_approves.each do |approve|
        if approve.is_approved?
          true
        else
          return false
        end
      end
    end

    if is_approved
      self.approve!
      SendVacationApprovalWorker.perform_async(id.to_s) if from >= Date.today
      self.send_notification_emails if self.from >= Date.today
    end
  end

  def notification_date(number_of_days, receiver = nil)
    (number_of_days.business_days.before(from).in_time_zone(receiver&.country&.time_zone || 'Europe/Kiev') + 10.hours).utc
  end

  def send_notification_emails
    return unless from >= Date.today

    # SendVacationNotificationWorker.perform_at(notification_date, id.to_s, 'hr@masterofcode.com')
    notification_receivers.each do |receiver|
      SendVacationNotificationWorker.perform_at(notification_date(2, receiver), id.to_s, receiver.moc_email)
    end
    return unless employee.country.name.eql?('USA')

    receiver = User.where(moc_email: 'tatiana.bened@masterofcode.com').first
    SendVacationNotificationWorker.perform_at(notification_date(5, receiver), id.to_s, receiver.moc_email)
  end

  def send_request_notification_emails
    return unless from >= Date.today && request_notification_receivers.present?

    request_notification_receivers.each do |receiver|
      SendVacationRequestNotificationWorker.perform_async(id.to_s, receiver.moc_email)
    end
  end

  def time_range_to_s(lang = 'eng')
    if lang == 'ua'
      from == to ? "#{from.strftime("%d-%m-%Y")} #{' (пів-дня)' if half_day?}" : "з #{from.strftime("%d-%m-%Y")} до #{to.strftime("%d-%m-%Y")}"
    else
      from == to ? "on #{from.strftime("%b %d") }#{' (half-day)' if half_day?}" : "from #{from.strftime("%b %d")} till #{to.strftime("%b %d")}"
    end
  end

  def count_days(year = nil, from = self.from, to = self.to)
    number_of_days = 0.0
    (from..to).each do |day|
      if year.present?
        unless (day.saturday? || day.sunday?) || Holiday.where(date: day, country: self.employee.country).any?
          number_of_days += 1 if day.year.eql?(year)
        end
      else
        unless (day.saturday? || day.sunday?) || Holiday.where(date: day, country: self.employee.country).any?
          number_of_days += 1;
        end
      end
    end
    number_of_days = (number_of_days.to_f / 2) if self.half_day?
    number_of_days
  end

  def process_days(revert = false, explicit = false, next_year = false)
    days = count_days
    days *= -1 if revert
    master = self.employee
    year = self.from.year
    current_year = Date.today.year
    previous_year_remaining_days = master.vacation_days_past_year
    current_year_remaining_days = master.remaining_vacation_days_current_year
    next_year_remaining_days = master.next_year_vacation_days_remaining
    case self.category
    when 'vacation'
      # old >>>
      if self.to.year > Date.today.year
          self.employee.previous_year_vacation_days_remaining = [previous_year_remaining_days, 0].max
        else
          self.employee.previous_year_vacation_days_remaining -= days
        end
      self.employee.vacation_days_used += days
        # <<< old

      if days.positive?
        previous_year_balance = get_balance(year - 1)
        current_year_balance = get_balance(year)
        subtract_limit = (previous_year_balance - days).negative? ? previous_year_balance : days
        remainder = days - subtract_limit
        update_days(year - 1, previous_year_balance, subtract_limit)
        update_days(year, current_year_balance, remainder)
      else
        max_vacation_days = master.vacation_days_for_year(year)
        days *= -1
        if year > Date.today.year
          next_year_balance = get_balance(year)
          current_year_balance = get_balance(year - 1)
          next_year_limit = (days + next_year_balance) > max_vacation_days ? (max_vacation_days - next_year_balance) : days.abs
          update_days(year, next_year_balance, next_year_limit * -1)
          remainder = days - next_year_limit
          if remainder.positive?
            current_year_limit =  (remainder + current_year_balance) > max_vacation_days ?  (max_vacation_days - current_year_balance) : remainder
            update_days(year - 1, current_year_balance, current_year_limit * -1)
            remainder -= current_year_limit
          end
          if remainder.positive?
            previous_year_balance = get_balance(year - 2)
            previous_year_limit =  (remainder + previous_year_balance) > max_vacation_days ?  (max_vacation_days - previous_year_balance) : remainder
            update_days(year - 2, previous_year_balance, previous_year_limit * -1)
          end
        else
          current_year_balance = get_balance(year)
          previous_year_balance = get_balance(year - 1)
          current_year_limit = (days + current_year_balance) > max_vacation_days ? max_vacation_days - current_year_balance : days.abs
          remainder = days.abs - current_year_limit
          update_days(year, current_year_balance, current_year_limit * -1)
          update_days(year - 1, previous_year_balance, remainder * -1) if remainder.positive?
        end
      end
    when 'sick'
        self.employee.sick_days -= days unless self.to.year < Date.today.year
    when 'days-off'
      if self.from.year > Date.today.year && !self.sick_leave_unpaid && explicit.eql?(false) #redundant
        self.employee.next_year_vacation_days_used += days  #old
        update_days(current_year + 1, next_year_remaining_days, days)
      else
        employee.days_off += days unless from.year > Date.today.year && explicit.eql?(true)
      end
    end
    self.employee.save
  end

  def update_days(year, remaining_days, days_to_subtract)
    master = self.employee
    additional_vacations = year < 2021 ? 0.0 : master.count_additional_vacations(year)
    processed = {year.to_s => (remaining_days - additional_vacations) - days_to_subtract}
    updated_info = master.annual_vacation_balance.map do |vac_obj|
      vac_obj = processed if vac_obj.keys.first.eql?(year.to_s)
      vac_obj
    end
    master.update_attributes(annual_vacation_balance: updated_info)
  end

  def get_balance(year)
    master = self.employee
    additional_vacations = year < 2021 ? 0.0 : master.count_additional_vacations(year) #2021-year since implementation of new logic
    vacation_hash = master.annual_vacation_balance.detect{|obj| obj.keys.first.eql?(year.to_s)}
    vacation_hash.present? ? vacation_hash[year.to_s] + additional_vacations : 0.0 + additional_vacations
  end

  def designer_vacation_emails
    leads_excluding_employee = User.current.community_leads(employee.community).excludes(id: employee)
    return unless leads_excluding_employee.present?

    leads_excluding_employee.each do |lead|
      SendCommunityLeadNotificationWorker.perform_async(id.to_s, lead.moc_email) if from >= Date.today
    end
  end

  def create_approves
    approvers[:first_level].each do |approver|
      next if approver.blank?
      approver.vacation_approves.create!(vacation: self)
      # SendVacationRequestsWorker.perform_async(vacation_approve.id.to_s) if self.from >= Date.today
    end
    if approvers[:second_level].present?
      approvers[:second_level].each do |approver|
        next if approver.blank?
        approver.vacation_approves.create!(vacation: self, second_level_approver: true)
        # VacationApprove.create!(vacation_id: id, manager_id: approver.id, second_level_approver: true)
      end
    end
  end

  def self.overlaps?(user, from, to, half_day)
    vacations = user.vacations.not_rejected.where(:from.lte => to, :to.gte => from)
    return false if vacations.size.zero?

    if half_day
      more_than_half_day_taken = vacations.where(half_day: false).size > 0 || vacations.where(half_day: true).size > 1
      more_than_half_day_taken ? true : false
    else
      true
    end
  end
end
