module Utils
  class DocxGenerator

    PAYEURS = %w(
      55d30ffe68726d2b01730000
      55d30fff68726d2b01750000
      55d30fff68726d2b01760000
      5a818f026463380066000000
    )

    VENDORS = {
      '55f81cae68726d3cda0b0000' => {'customer' => %w(Замовник Замовником), 'vendor' => %w(Виконавець Виконавцем)},
      '592eaaf432393100963c0000' => {'customer' => %w(Орендар Орендарем), 'vendor' => %w(Орендодавець Орендодавцем)},
      '57a454b462396425990a0000' => {'customer' => %w(Суборендар Суборендарем), 'vendor' => %w(Суборендодавець Суборендодавцем)},
      '5c73db6c63393600058b0000' => {'customer' => %w(Суборендар Суборендарем), 'vendor' => %w(Суборендодавець Суборендодавцем)}
    }

    PASSPORT_INFO = {
      full_name: 'full_name',
      full_name_short: "full_name({format: 'short'})",
      full_name_short_gc: "full_name({format: 'short', genitive_case: true})",
      edrpou: 'edrpou',
      edrpou_short_2: 'edrpou[0, 2]',
      edrpou_short_3: 'edrpou[0, 3]',
      edrpou_short_4: 'edrpou[0, 4]',
      address: 'address',
      address_eng: 'address_eng',
      passport: 'passport_number',
      rvu: 'rvu',
      contract_number: 'exporter_number',
      contract_date: 'contract_date',
      contract_number_kg: 'contract_number_kg',
      contract_date_kg: 'contract_date_kg',
      accounting_agreement_date: 'accounting_agreement_date&.strftime("%d.%m.%Y")',
      equipment_rent_agreement_date: 'equipment_rent_agreement_date&.strftime("%d.%m.%Y")',
      first_rent_agreement_date: 'first_rent_agreement_date&.strftime("%d.%m.%Y")',
      second_rent_agreement_date: 'second_rent_agreement_date&.strftime("%d.%m.%Y")',
    }

    BANK_INFO = {
      bank_ua: 'info(:name_ua)',
      bank_eng: 'bank',
      legal_address_ua: 'info(:legal_address_ua)',
      legal_address_eng: 'info(:legal_address_eng)',
      swift_number: 'info(:swift_number)',
      correspondent_bank: 'info(:correspondent_bank)',
      mfo: 'mfo',
      current_account: 'current_account',
      usd_account: 'beneficiary_bank_acc',
      iban_code: 'beneficiary_IBAN_acc',
    }

    FIRMS = ['MOCG', 'KGOU']

    attr_accessor :template_name, :user, :options

    def initialize(template_name, user, options = {})
      self.user = user
      self.options = options
      self.template_name = get_template_name(template_name)
    end

    def generate
      if self.options[:jira].present?
        project_info = Utils::JiraLibrary::JiraManager.new(instance: Utils::JiraLibrary::JiraManager::MOCG).data(@user,Date.parse(self.options[:from]), Date.parse(self.options[:to]), options[:jira])
      end
      if self.options[:per_project].present? && project_info.size > 1
        zipfile_name = "#{Rails.root}/tmp/#{self.user.full_name} #{self.template_name}.zip"
        File.delete(zipfile_name) if File.exist?(zipfile_name)
        handles = []
        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          project_info.each do |project_info_entry|
            self.options[:project_info] = project_info_entry
            file = self.create_doc
            handles << file
            zipfile.add(self.filename, File.join(file.path))
          end
        end
        handles = nil
        {name: zipfile_name, type: 'application/zip', disposition: 'attachment'}
      else
        self.options[:project_info] = options[:jira] == 'project' ? project_info.first : project_info
        file = self.create_doc
        {path: file.path, name: self.filename, disposition: 'attachment'}
      end
    end

    def create_doc
      @doc = DocxReplace::Doc.new("#{Rails.root}/lib/docx_templates/#{self.template_name}", "#{Rails.root}/tmp")
      @errors = []
      self.fill_doc
      tmp_file = Tempfile.new('word_template', "#{Rails.root}/tmp")
      if @errors.present?
        tmp_file.puts "#{@errors}"
        tmp_file.close
      else
        # Write the document back to a temporary file
        @doc.commit(tmp_file.path)
      end
      tmp_file
    end

    def fill_doc
      doc_replace('$date$', Date.current.strftime('%d.%m.%Y'))
      doc_replace('$date$', Date.current.strftime('%d.%m.%Y'))
      doc_replace('$slash_date$', Date.current.strftime('%d/%m/%Y'))
      doc_replace('$end_date$', (Date.current + 1.months).strftime('%d.%m.%Y'))
      doc_replace('$end_date_after_year$', (Date.current + 1.year).strftime('%d.%m.%Y'))
      doc_replace('$from$', self.options[:from]) if self.options[:from].present?
      if self.options[:to].present?
        doc_replace('$to$', self.options[:to])
        doc_replace('$year_end$', Date.parse(self.options[:to]).end_of_year.strftime('%d.%m.%Y'))
      end
      doc_replace('$chosen_date$', Date.parse(self.options[:chosen_date]).strftime('%d.%m.%Y')) if self.options[:chosen_date].present?
      doc_replace('$slash_chosen_date$', Date.parse(self.options[:chosen_date]).strftime('%d/%m/%Y')) if self.options[:chosen_date].present?
      doc_replace('$quarter_year$', "0#{Date.current.end_of_quarter.month/3}#{Date.current.strftime('%y')}")

      self.master_info(self.user)
      if self.options[:service_provider_id]
        self.master_info(User.find(self.options[:service_provider_id]), 'm_')
        if VENDORS[self.options[:service_provider_id]].present?
          doc_replace('$customer$', VENDORS[self.options[:service_provider_id]]['customer'].first.force_encoding('ASCII-8BIT'))
          doc_replace('$customer_case$', VENDORS[self.options[:service_provider_id]]['customer'].second.force_encoding('ASCII-8BIT'))
          doc_replace('$vendor$', VENDORS[self.options[:service_provider_id]]['vendor'].first.force_encoding('ASCII-8BIT'))
          doc_replace('$vendor_case$', VENDORS[self.options[:service_provider_id]]['vendor'].second.force_encoding('ASCII-8BIT'))
        end
      end
      self.equipment_info if self.options[:equipment].present?
      self.project_info if self.options[:project_info].present?
      self.accounting_info if self.options[:acc_module].present?
    end

    def master_info(user, prefix='')
      doc_replace('$full_name_eng$', user.full_name)

      return unless user.passport_info.present?
      source = user.passport_info
      PASSPORT_INFO.each do |var, field|
        eval get_doc_replace(prefix, var, field)
      end

      return unless user.bank_accounts.present?
      source = nil
      bank_accounts = user.bank_accounts
      if bank_accounts.count > 1
        bank = Acc::Sourcebook.by_master_id(user.id.to_s)&.first&.bank
        source = user.bank_accounts.find_by(bank: bank) if bank.present?
      else
        source = user.bank_accounts.first
      end
      return unless source.present?
      BANK_INFO.each do |var, field|
        eval get_doc_replace(prefix, var, field)
      end
    end

    def equipment_info
      doc_replace('$edrpou_admin_3$', User.find_by(moc_email: 'yuliia.horobets@masterofcode.com').passport_info.edrpou[0, 3])

      hardwares = SnipeItManager.new(user.moc_email).user_hardwares
      hardware_info = []

      self.user.hardwares.where(type: 'display').each do |display|
        hardware_info << "N #{display.uid} #{display.type} #{display.vendor} #{display.model}"
      end
      hardwares.select {|h| h[:category] == 'Display'}.each do |hardware|
        hardware_info << "#{hardware[:category]} #{hardware[:name]} (#{hardware[:tag]})"
      end
      (0..4).each do |n|
        info = hardware_info[n].present? ? hardware_info[n] : ''
        doc_replace("$hardware_info#{n}$", info)
      end

      pc_info_mm = self.user.pcs.first.present? ? "PC #{self.user.pcs.first.uid}" : ''
      pcs = hardwares.select {|h| h[:category] == 'Desktop'}
      pc_info = pcs.first.present? ? "PC #{pcs.first[:name]} (#{pcs.first[:tag]})" : ''
      info = pc_info.present? ? pc_info : pc_info_mm
      doc_replace('$pc$', info)

      pc_hardware_info = []
      if self.user.pcs.first.present? && info == pc_info_mm
        self.user.pcs.first.hardwares.where(:type.ne => 'display').each do |hardware|
          pc_hardware_info << "Type #{hardware.type} #{hardware.vendor} #{hardware.model}"
        end
      end
      other_hardware_info = []
      hardwares.select {|h| !h[:category].in?(%w(Display Desktop Permission))}.each do |hardware|
        tag = hardware[:tag].present? ? "(#{hardware[:tag]})" : ''
        other_hardware_info << "#{hardware[:category]} #{hardware[:name]} #{tag}"
      end
      hardware_info = pc_hardware_info + other_hardware_info
      (0..8).each do |n|
        info = hardware_info[n].present? ? hardware_info[n] : ''
        doc_replace("$pc_hardware_info#{n}$", info, true)
      end

      pc_warning = pcs.count > 1 ? 'Master has more then one PC!!!' : ''
      doc_replace('$pc_warning$', pc_warning)
    end

    def project_info
      if self.options[:per_project].present?
        project_info = self.options[:project_info]
      else
        project_info = ''
        self.options[:project_info].each do |project_name, project_issues|
          project_info += "\n     #{project_name}: \n"
          project_issues&.each_with_index do |project_issue, index|
            project_info += "#{index+1})  #{project_issue['issue_type']} - #{project_issue['issue']}; \n"
          end
        end
      end
      doc_replace("$project_info$", project_info, true)
    end

    def accounting_info
      if options[:acc_module] == 'charges'
        from = Date.parse(self.options[:from])
        to = Date.parse(self.options[:to])

        date_range = (from+1.month)..(to+1.month)
        months_years = date_range.map {|date| Date.new(date.year, date.month, 1)}.uniq
        months_years = months_years.map {|date| {:month => date.month, :year => date.year}}

        charges = Money.new(0)
        months_years.each do |period|
          row = Acc::ReportRow.report(Acc::Constants::GENERAL_REPORT).for_month(period[:month]).for_year(period[:year]).for_master(self.user.id.to_s)
          charges += Monetize.parse(row&.first&.row_data&.dig("report","MASTERS.WORK","turnover"))
        end
        doc_replace('$charges$', charges.format)
      end

      if options[:acc_module] == 'rent'
        doc_replace('$from$', self.options[:from])
        doc_replace('$to$', self.options[:to])

        rate_period = Date.today - 1.month
        row = Acc::ReportRow.report(Acc::Constants::GENERAL_REPORT).for_month(rate_period.month).for_year(rate_period.year).for_master(self.user.id.to_s)
        rate = Contractor.new(self.user.id.to_s).personal_dictionary_value("PERSONAL.MASTER.RATE").present? ? Contractor.new(self.user.id.to_s).personal_dictionary_value("PERSONAL.MASTER.RATE").debit_balance : Money.new(0)
        rate = rate*1.0537
        report = row&.first&.row_data&.dig("report")
        if report.present?
          expenses = Monetize.parse(report&.dig("CHARGES.TAXES","turnover")) +
            Monetize.parse(report&.dig("CHARGES.ACCOUNTANT","turnover")) + Monetize.parse(report&.dig("CHARGES.RENT","turnover")) +
            Monetize.parse(report&.dig("CHARGES.EQUIPMENT_RENT","turnover")) + Monetize.parse(report&.dig("CHARGES.BANK","turnover"))
          rate += expenses*1.0537/160
        end
        rate = rate.format.gsub('$','')

        doc_replace('$rate$', rate)
      end
    end

    def self.payeurs
      User.where(:id.in => PAYEURS)
    end

    def self.vendors
      User.where(:id.in => VENDORS.keys)
    end

    def filename
      filename =
        if self.template_name.include?('Statement of work')
          project_info = self.options[:project_info]&.gsub('/',',')
          "#{self.user.full_name}_SOW_#{project_info}_#{self.options[:to]}.docx"
        elsif self.template_name.include?('Transfer and acceptance certificate')
          "#{self.user.full_name}_TAC_#{self.options[:from].to_date.end_of_quarter.month/3}Q.docx"
        else
          "#{self.user.full_name} #{self.template_name}"
        end
      @errors.present? ? "#{filename}.txt" : filename
    end

    def doc_replace(pattern, replacement, substitute_symbols = false)
      if substitute_symbols
        replacement = replacement.gsub('&','and').gsub('<','(').gsub('>',')').gsub('®','').force_encoding("ASCII-8BIT")
      end

      begin
        @doc.replace(pattern, replacement, true)
      rescue => error
        @errors << error.message
      end
    end

    def get_doc_replace(prefix, var, field)
      "doc_replace('$#{prefix}#{var}$', source.#{field}.to_s)"
    end

    private

    def get_template_name(template_name)
      if self.options[:check_contract_type].present? && self.user.passport_info.contract_type == 'New'
        template_name = "#{template_name.split('.')[0]} new.#{template_name.split('.')[1]}"
      end
      if self.options[:firms].present?
        template_name = "#{template_name.split('.')[0]} #{options[:firms]}.#{template_name.split('.')[1]}"
      end
      template_name
    end
  end
end
