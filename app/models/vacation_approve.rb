class VacationApprove
  include Mongoid::Document

  field :is_approved, type: Boolean
  field :comment, type: String
  field :second_level_approver, type: Boolean, default: false

  belongs_to :vacation
  belongs_to :manager , class_name: 'User'

  scope :approved, -> { where(is_approved: true) }

  def self.vacation_request_reminder
    managers = User.with_role :manager
    managers.each do |manager|
      if manager.has_unattended_approves?
        SendVacationRequestsWorker.perform_async(manager.id.to_s)
      end
    end
  end

end
