class AdditionalVacation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Paranoia

  field :comment, type: String
  field :days, type: Float, default: 0
  field :assigned_by, type: String

  embedded_in :user
end
