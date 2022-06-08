class MasterModuleApi::V1::VacationApproves < Grape::API
  namespace :vacation_approves do
    desc 'confirm a vacation request'
    params do
      requires :id, type: String, allow_blank: false
    end
    post :confirm do
      respond_with Employee::VacationApproves::ConfirmVacation
    end


    desc 'reject a vacation request'
    params do
      requires :id, type: String, allow_blank: false
      requires :comments, type: String
    end
    post :reject do
      respond_with Employee::VacationApproves::RejectVacation
    end
  end
end

