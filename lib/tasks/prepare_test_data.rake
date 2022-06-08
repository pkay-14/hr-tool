task :prepare_test_data => :environment do
  require 'faker'
  Faker::UniqueGenerator.clear

  num = 0
  User.current_employee.each do |user|
    next if user.last_name.eql?('Quaye')
    process_user(user, true)
    num += 1
    p "user #{num}"
  end

  (User.all - User.current_employee).each do |user|
    process_user(user, false)
    num += 1
    p "user #{num}"
  end

  Overtime.each {|overtime| overtime.update_attributes({_keywords: overtime.employee&._keywords})}
  Vacation.each {|vacation| vacation.update_attributes({_keywords: vacation.employee&._keywords})}

  email_aliases = %w(
    default_vacation_approver@masterofcode.com
    default_foreign_master_vacation_approver@masterofcode.com
    pm_vacation_approver@masterofcode.com
    ba_lead@masterofcode.com
    lp_pm_vacation_approver@masterofcode.com
    pm_overtime_approver@masterofcode.com
    devops_and_designers_overtime_approver@masterofcode.com
    lp_project_manager.hrom@masterofcode.com
  )

  users = User.current_employee
  email_aliases.each_with_index do |email_alias, i|
    user = users[i]
    user.update_attributes({ moc_email: email_alias })
  end

  test_users = [
    { last_name: 'Master', email: 'master_test@gmail.com', moc_email: 'master_test@masterofcode.com' },
    { last_name: 'Lead', email: 'lead_test@gmail.com', moc_email: 'lead_test@masterofcode.com', role: :lead },
    { last_name: 'Manager', email: 'manager_test@gmail.com', moc_email: 'manager_test@masterofcode.com', role: :manager },
    { last_name: 'HR', email: 'hr_test@gmail.com', moc_email: 'hr_test@masterofcode.com', role: :hr_manager },
    { last_name: 'System Administrator', email: 'sys_admin_test@gmail.com', moc_email: 'sys_admin_test@masterofcode.com', role: :admin },
    { last_name: 'Acc Assistant', email: 'acc_assistant@gmail.com', moc_email: 'acc_assistant@masterofcode.com', role: :acc_assistant },
  ]
  test_users.each do |test_user|
    User.create(test_user.except(:moc_email, :role).merge({ first_name: '_Test', password: '123456789', hired_at: '2021.01.01'.to_date })) do |u|
      u.update_attributes!({ moc_email: test_user[:moc_email], country: Country.find_by(name: 'Ukraine') })
      u.update_attributes!({ jira_account_id: '5afea30d85792855f9943bf7' }) if u.moc_email == 'sys_admin_test@masterofcode.com'
      u.add_role(:employee)
      u.add_role test_user[:role] if test_user[:role].present?
    end
  end
end



def process_user(user, uniq)
  gender = ['male', 'female'].sample
  Faker::Config.locale = 'en'

  user.remove_photo
  first_name = gender.eql?('male') ? Faker::Name.male_first_name : Faker::Name.female_first_name
  last_name = uniq ? Faker::Name.unique.last_name : Faker::Name.last_name
  email = "#{first_name.downcase}.#{last_name.downcase}@gmail.com"
  comments = Faker::Lorem.sentence(word_count: 25) if user.comments.present?
  left_comment = Faker::Lorem.sentence(word_count: 15)
  reference = Faker::Lorem.sentence(word_count: 2)
  reference_additional = Faker::Lorem.sentence(word_count: 3)

  user.update_attributes!({
                            first_name: first_name, last_name: last_name,
                            email: email, comments: comments,
                            resume_url: '', left_comment: left_comment,
                            reference: reference, reference_additional: reference_additional
                          })

  user.additional_vacations.each do |vacation|
    vacation.update_attributes!({ comment: Faker::Lorem.sentence(word_count: 15) }) if vacation.comment.present?
  end
end

