task :change_to_role => :environment do
  User.all.each{|user| user.remove_role :candidate ;  user.remove_role :employee ; user.save;}
  candidates = User.candidates
  employees = User.employee
  puts candidates.count
  candidates.each{|candidate| candidate.change_to_candidate!}
  puts User.candidates.count
  p "!!!!!!!!!!!!!"
  p employees.count
  p "employee - #{employees.current_employee.count} "
  p "interviewer - #{employees.current_interviewers.count} "
  p "left - #{employees.left_employee.count} "

  employees.each{|employee| employee.change_to_employee!}
  employees_new =User.employee_old
  p "!!!!!!!###!!!"
  p employees_new.count
  p "employee - #{employees_new.current_employee.count} "
  p "interviewer - #{employees_new.current_interviewers.count} "
  p "left - #{employees_new.left_employee.count} "
  end
