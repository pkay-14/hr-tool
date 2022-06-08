module Admin::LawyerInfoHelper
 GDOCS_INFO = [
   {:title => 'договір про бухпослуги', :template_name => 'HR_Bookkeeping.docx', :options => {:chosen_date => Date.today.strftime('%d.%m.%Y')}},
   {:title => 'договір суборенди (Лихолай)', :template_name => 'HR_Liholay_Contract.docx', :options => {:chosen_date => Date.today.strftime('%d.%m.%Y')}},
   {:title => 'договір суборенди (Кудря)', :template_name => 'HR_Kudrya_Contract.docx', :options => {:chosen_date => Date.today.strftime('%d.%m.%Y')}},
   {:title => 'створити договір суборенди (Київ)', :template_name => 'LIFT99_Lykholai.docx', :options => {:chosen_date => Date.today.strftime('%d.%m.%Y')}},
   {:title => 'договір про підвищення кваліфікації', :template_name => 'HR_Trial_Mentorship_Agreement_Order_.docx',
    :options => {:service_providers => User.current_employee}},
   {:title => 'договір про надання послуг', :template_name => 'Contractor Agreement.docx',
    :options => {:chosen_date => Date.today.strftime('%d.%m.%Y'), :firms => Utils::DocxGenerator::FIRMS}},
   {:title => 'договір оренди обладнання', :template_name => 'Equipment_Rent.docx',
    :options => {:equipment => true, :chosen_date => Date.today.strftime('%d.%m.%Y')}},
   {:title => 'додатковий договір оренди обладнання', :template_name => 'Additional_agreement_equipment_rent.docx',
    :options => {:equipment => true}},
   {:title => 'акт оренди обладнання', :template_name => 'АКТ ОРЕНДИ ОБЛАДНАННЯ.docx',
    :options => {:equipment => true, :chosen_date => Date.today.strftime('%d.%m.%Y')}},
   {:title => 'акт приймання-передачі бух. послуг', :template_name => 'АКТ ПРИЙМАННЯ-ПЕРЕДАЧІ БУХ.docx',
    :options => {:chosen_date => Date.today.strftime('%d.%m.%Y')}},
   {:title => 'акт оренди (Лихолай)', :template_name => 'АКТ ОРЕНДИ ЛИХОЛАЙ.docx',
   :options => {:chosen_date => Date.today.strftime('%d.%m.%Y')}},
   {:title => 'акт оренди (Кудря)', :template_name => 'АКТ ОРЕНДИ КУДРЯ.docx',
    :options => {:chosen_date => Date.today.strftime('%d.%m.%Y')}},
   {:title => 'додаткову угоду про розірвання договору', :template_name => 'Додаткова угода про розірвання договорів.docx',
    :options => {:service_providers => Utils::DocxGenerator.vendors}},
   {:title => 'акт виконаних робіт', :template_name => 'Transfer and acceptance certificate.docx',
    :options => {:from => (Date.today - 3.months).at_beginning_of_quarter.strftime('%d.%m.%Y'),
                 :to => (Date.today - 3.months).at_end_of_quarter.strftime('%d.%m.%Y'), :jira => :issue, :acc_module => :charges, :check_contract_type => true}},
   {:title => 'технічне завдання', :template_name => 'Statement of work.docx',
    :options => {:from => Date.today.at_beginning_of_year.strftime('%d.%m.%Y'),
                 :to => Date.today.strftime('%d.%m.%Y'), :per_project => true, :jira => :project, :acc_module => :rent, :check_contract_type => true,
                 :firms => Utils::DocxGenerator::FIRMS}},
   {:title => 'угоду про розірвання договору про надання послуг', :template_name => 'Supplementary-Agreement-on-Termination.docx',
    :options => {:chosen_date => Date.today.strftime('%d.%m.%Y')}},
   {:title => 'договір про взаємне нерозголошення', :template_name => 'NDA_MOCG.docx',
    :options => {:chosen_date => Date.today.strftime('%d.%m.%Y')}},
 ]

 BULK_DOCS = ['акт оренди обладнання', 'акт приймання-передачі бух. послуг', 'акт оренди (Лихолай)', 'акт оренди (Кудря)',
              'договір про бухпослуги', 'договір суборенди (Лихолай)', 'договір суборенди (Кудря)', 'договір оренди обладнання']

 BULK_GDOCS_INFO = GDOCS_INFO.select {|doc| doc[:title].in?(BULK_DOCS)}

end
