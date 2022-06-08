class Contractor


  attr_accessor :hr_module_user
  attr_accessor :id, :first_name, :last_name
  attr_accessor :import_link


  def initialize(id, first_name="Test Master First", last_name="Test Master Last")
    self.id=id

    self.hr_module_user = User.where(id: id).entries.first

    unless self.hr_module_user
      self.first_name=first_name
      self.last_name=last_name
    else
      self.first_name =hr_module_user.first_name
      self.last_name = hr_module_user.last_name
    end
  end


  def real?
    self.hr_module_user && self.hr_module_user.respond_to?(:first_name) && self.hr_module_user.respond_to?(:last_name)
  end

  def last_entry_time
    "1970-01-01"
  end

  def method_missing(m, *args, &block)
    self.hr_module_user.send(m, *args, &block) if self.real?
  end

  def not_payed?
    work_account = Acc::Account.by_master_id(self.id).by_sub_type(Acc::Constants::INVOICES_CALCULATED).first
    Acc::Entry.for_contractor(self.id).with_credit_account(work_account).where("operation_date>=? and sum_cents>0 ", Date.today-30.days).first.nil?
  end

  def work_rate_defined?
    result=Acc::Account.by_master_id(self.id).by_sub_type(Acc::Constants::INFO_MASTER_RATE).first
    !result.nil? && result.debit_balance>0
  end

  def lawyer_rate_defined?
    result=Acc::Account.by_master_id(self.id).by_sub_type(Acc::Constants::INFO_LAWYER_RATE).first
    !result.nil? && result.debit_balance>0
  end

  def accontant_rate_defined?
    result=Acc::Account.by_master_id(self.id).by_sub_type(Acc::Constants::INFO_ACCOUNTANT_RATE).first
    !result.nil? && result.debit_balance>0
  end

  def tax_rate_defined?
    result=Acc::Account.by_master_id(self.id).by_sub_type(Acc::Constants::INFO_TAXES_RATE).first
    !result.nil? && result.debit_balance>0
  end

  def rent_rate_defined?
    result=Acc::Account.by_master_id(self.id).by_sub_type(Acc::Constants::INFO_RENT_RATE).first
    !result.nil? && result.debit_balance>0
  end

  def rates_defined?
    work_rate_defined?&&lawyer_rate_defined?&&accontant_rate_defined?&&tax_rate_defined?&&rent_rate_defined?
  end


  def self.contractors(users)

    result=[]

    users.sort_by(&:last_name).each do |user|
      contractor = Contractor.new(user.id)
      result.push(contractor) if contractor.real?
    end

    result
  end

  def self.contractors_options(users)

    self.contractors(users).collect {|contractor| [contractor.full_name, contractor.id]}

  end


  def invoices_calculated
    acc = Acc::Account.by_sub_type(Acc::Constants::INVOICES_CALCULATED).by_master_id(self.id).first
    !acc.nil? ? acc.credit_balance : 0
  end

  def invoices_sent
    acc=Acc::Account.by_sub_type(Acc::Constants::INVOICES_CREATED).by_master_id(self.id).first
    !acc.nil? ? acc.credit_balance : 0
  end


  def invoices_payed
    acc=Acc::Account.by_sub_type(Acc::Constants::INVOICES_PAYED).by_master_id(self.id).first
    !acc.nil? ? acc.credit_balance : 0
  end

  def last_invoice_time

  end

  def work_calculated?
    personal_balance(Acc::Constants::MASTERS_WORK).to_f > 0
  end

  def pre_calculated?
    invoices_calculated.to_f==0
  end

  def invoice_calculated?
    invoices_calculated.to_f>0
  end

  def sent?
    invoices_sent.to_f>0
  end

  def payed?
    invoices_sent==0 && invoices_sent==0 && !not_payed?
  end

  def personal_turnover(account, date = Date.today, months=12)
    acc = Acc::Account.by_sub_type(account).by_master_id(self.id).first

    if acc

      if acc.active?
        result = Acc::Entry.where(" status=? and debit_account_id=? and operation_date>=? and operation_date<=? and master_id=?", Acc::Entry::STATUS_ACCEPTED, acc.id, (date-(months-1).month).beginning_of_month, date.end_of_month, self.id.to_s).select("date_part('month', operation_date) as month, date_part('year', operation_date) as year,SUM(default_currency_sum_cents) as turnover").group("year, month").order("year, month")
      elsif acc.passive?
        result = Acc::Entry.where(" status=? and credit_account_id=? and operation_date>=? and operation_date<=? and master_id=?", Acc::Entry::STATUS_ACCEPTED, acc.id, (date-(months-1).month).beginning_of_month, date.end_of_month, self.id.to_s).select("date_part('month', operation_date) as month, date_part('year', operation_date) as year,SUM(default_currency_sum_cents) as turnover").group("year, month").order("year, month")
      elsif acc.active_passive?
        result = Acc::Entry.where(" status=? and (debit_account_id=? or credit_account_id=?) and operation_date>=? and operation_date<=? and master_id=?", Acc::Entry::STATUS_ACCEPTED, acc.id, acc.id, (date-(months-1).month).beginning_of_month, date.end_of_month, self.id.to_s).select("date_part('month', operation_date) as month, date_part('year', operation_date) as year, SUM( CASE credit_account_id WHEN #{acc.id} THEN default_currency_sum_cents ELSE 0 END) as income, SUM( CASE debit_account_id WHEN #{acc.id} THEN default_currency_sum_cents ELSE 0 END) as expense").group("year, month").order("year, month")
      end
      if result
        result.collect do |month|
          if month.respond_to?(:turnover)
            [Date.new(month.year, month.month, 1).strftime("%Y/%B"), Money.new(month.turnover)]
          else
            [Date.new(month.year, month.month, 1).strftime("%Y/%B"), Money.new(month.income - month.expense)]
          end
        end
      else
        []
      end

    else
      []
    end
  end

  def personal_balance(account)
    account = Acc::Account.by_master_id(self.id).by_sub_type(account).first
    if account
      if account.active?
        account.debit_balance
      elsif account.passive?
        account.credit_balance
      elsif account.active_passive?
        account.debit_balance > 0 ? account.debit_balance*-1 : account.credit_balance
      end
    end
  end


  def personal_turnover_total(account, date = Date.today, months=12)
    result = self.personal_turnover(account, date, months).sum {|month| month[1]}
    if result == 0
      Money.new(0)
    else
      result
    end
  end

  def personal_dictionary_value(account)
    Acc::Account.by_master_id(self.id.to_s).by_sub_type(account).first
  end

  def self.monthly_rates
    CSV.generate(headers: false) do |csv|
      entries = Acc::Entry.with_transaction_type_id(Acc::Constants::SET_MASTER_RATE).status_accepted
      contractors = Contractor.contractors(User.current_employee)
      contractors.each do |contractor|
        next unless Acc::Sourcebook.by_master_id(contractor.id)&.first&.calculate
        row_info = []
        entry = entries.for_contractor(contractor.id).last
        row_info << contractor.full_name
        rate = entry&.sum.to_f
        row_info << (Acc::Constants::TARGET_TIME * rate / 5).round * 5
        date = entry&.operation_date ? entry.operation_date.strftime('%d-%m-%Y') : ''
        row_info << date
        csv << row_info
      end
    end
  end

  def personal_dictionary_history(action)
    entries = Acc::Entry.for_contractor(self.id).with_transaction_type_id(action).before_date(Date.today).status_accepted.order("operation_date desc, created_at desc")
    if entries.any?
      dictionary_history = entries.map {|entry| {entry.operation_date => entry.sum}}.uniq
      if [Acc::Constants::SET_ACCOUNTANT_RATE, Acc::Constants::SET_RENT_RATE, Acc::Constants::SET_EQUIPMENT_RENT_RATE].include? action
        arr = []
        _dictionary_history = []
        dictionary_history.reverse!.each do |record|
          unless arr.include?(record.values.first)
            arr << record.values.first
            _dictionary_history << record
          end
        end
        _dictionary_history.reverse!
      else
        dictionary_history
      end
    else
      []
    end
  end

  def monthly_invoices_total(month, year, monthly_contract)
    projects_sums = Acc::TimeEntry.monthly_by_master(month, year, import_link).entries
    total = projects_sums.sum {|item| item["total_hours"]}

    unless total.blank?
      projects_sums.collect {|item| {project_id: item["project_id"], total_hours: item["total_hours"], share: (item["total_hours"]/total.to_f)*monthly_contract}}
    else
      []
    end
  end

  def hourly_rate
    personal_balance(Acc::Constants::INFO_MASTER_RATE)
  end

  def import_link
    unless @import_link
      @import_link=Acc::ImportLink.by_master_id(self.id)
    end
    @import_link
  end

  def tax_group
    self.import_link.tax_group
  end

  def tax_group=(new_group)
    self.import_link.update_attribute(:tax_group, new_group)
  end

  def charges_for_tax(operational_date)
    charges_account = Acc::Account.by_sub_type(Acc::Constants::MASTERS_WORK).by_master_id(self.id).first
    result = Acc::Entry.with_credit_account(charges_account).from_date(operational_date.beginning_of_month).before_date(operational_date.end_of_month).status_accepted
    result.to_a.inject(0) {|sum, e| sum + e.sum}
  end


  def outer_invoice(month, year)

    outer_invoice = Acc::OuterInvoice.where(month: month, year: year, uat_acceptor_id: self.import_link.id).first

    unless outer_invoice
      outer_invoice = Acc::OuterInvoice.new
      outer_invoice.uat_acceptor_id = self.import_link.id
      outer_invoice.month = month
      outer_invoice.year= year
      outer_invoice.save
    end

    outer_invoice
  end

end
