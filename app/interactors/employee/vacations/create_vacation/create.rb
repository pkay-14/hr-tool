class Employee::Vacations::CreateVacation::Create
  include Interactor

  def call
    context.fail!(error: 422, message: 'couldn\'t create vacation') unless create_vacation
    # context.fail!(error_code: 422, error: 'couldn\'t create vacation') unless create_vacation
    context.response = { status: 200 }
  end

  private

  def create_vacation
    return unpaid_leave if context.params[:category].eql?('days-off')
    master = context.master
    vacations_params = [context.params.dup]
    if quota_exceeded?
      if context.params[:to].to_date.year > Date.today.year
        quota = context.params[:category] == 'vacation' ? master.vacation_days_current_year : 0.0
      else
        quota = context.params[:category] == 'vacation' ? master.vacation_days : master.sick_days_remaining
      end
      unless context.params[:category].eql?( 'vacation') && context.params[:to].to_date.year > Date.today.year
        if quota > 0
          if quota.eql?(0.5) && working_days > quota
            vacations_params[0][:category] = 'days-off'
          else
            from = context.params[:from].to_date
            to = paid_vacation_end(from, quota)
            vacations_params[0][:to] = to.strftime('%d.%m.%Y')
            vacations_params << context.params
            vacations_params[1][:from] = (to + 1).strftime('%d.%m.%Y')
            vacations_params[1][:category] = 'days-off'
            vacations_params[1][:sick_leave_unpaid] = vacations_params[0][:category].eql?('sick') || vacations_params[0][:sick_leave_unpaid].to_s.eql?("true")
          end
        else
          vacations_params[0][:sick_leave_unpaid] = vacations_params[0][:category].eql?('sick') || vacations_params[0][:sick_leave_unpaid].to_s.eql?("true")
          vacations_params[0][:category] = 'days-off'
        end
      else
        return create_records(master, vacations_params)
      end
    end

    if quota_exceeded? && context.params[:category] == 'sick'
      quota = context.params[:to].to_date.year > Date.today.year ? 0.0 : master.sick_days_remaining
      quota_info = {total: working_days, quota: quota, excess: working_days - quota}
      SendVacationQuotaExceededNotificationWorker.perform_async(context.master.id.to_s,'hr@masterofcode.com', quota_info)
    end
    create_records(master, vacations_params)
  end

  def create_records(master, vacations_params)
    vacations_params.each do |vacation_params|
      vacation = Vacation.create!(vacation_params.except(:master_id).merge(modifier: context.current_user, employee_id: master.id))
      if vacation.category == 'sick'
        vacation.approve!
        vacation.send_notification_emails
      else
        vacation.create_approves
      end
      vacation.send_request_notification_emails
      vacation.designer_vacation_emails if master.community.eql?('Design')
      vacation.process_days(false, false, vacation.to.year > Date.today.year)
    end
  end

  def quota_exceeded?
    master = context.master
    vacation_params = context.params
    if vacation_params[:to].to_date.year > Date.today.year
      (vacation_params[:category] == 'vacation' && working_days > master.remaining_vacation_days_current_year) ||
        (vacation_params[:category] == 'sick' && working_days.positive?)

    else
      (vacation_params[:category] == 'vacation' && working_days > (master.vacation_days)) ||
        (vacation_params[:category] == 'sick' && working_days > master.sick_days_remaining)
    end
  end

  def working_days
    vacation_params = context.params
    working_days = 0.0
    return working_days unless vacation_params[:from].present? || vacation_params[:to].present?

    (vacation_params[:from].to_date..vacation_params[:to].to_date).each do |day|
      unless (day.saturday? || day.sunday?) || Holiday.where(date: day, country: context.master.country).any?
        working_days += 1.0;
      end
    end
    to_boolean(vacation_params[:half_day]) ? working_days/2 : working_days
  end

  def paid_vacation_end(from, working_days)
    working_days -= 1 if Calendar.working_day?(from, context.master.country)
    to = from
    working_days.to_i.times do
      begin
        to += 1
      end until Calendar.working_day?(to, context.master.country)
    end
    to
  end

  def unpaid_leave
    context.vacation = Vacation.create!(context.params.except(:master_id).merge(modifier: context.current_user, employee_id: context.master.id, explicit: true))
    context.vacation.create_approves
    context.vacation.send_request_notification_emails
    context.vacation.designer_vacation_emails if context.master.community.eql?('Design')
    context.vacation.process_days(false, true)
  end

  def to_boolean(str)
    str.in?(%w(true 1))
  end

end
