class MasterModuleApi::V1::Vacations < Grape::API
  namespace :vacations do
    desc 'create a vacation'
    before do
      raise_error(403, 'Forbidden', {}, "#{request.base_url}/forbidden") unless current_user.is_hr_manager? || current_user.is_manager? || master_cabinet?
    end
    params do
      requires :master_id, type: String, allow_blank: false
      requires :category, type: String, allow_blank: false
      requires :from, type: String, allow_blank: false
      requires :to, type: String, allow_blank: false
      requires :notes, type: String
      requires :half_day, type: String
      # requires :sick_leave_unpaid, type: String
    end
    post :create do
      respond_with Employee::Vacations::CreateVacation
    end

    desc 'calculations for time off pop-up'
    params do
      requires :master_id, type: String, allow_blank: false
      requires :date, type: String, allow_blank: false
    end
    post :vacation_details do
      respond_with Employee::Vacations::VacationDetails
    end
  end
end
