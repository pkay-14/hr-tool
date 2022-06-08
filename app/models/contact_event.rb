class ContactEvent
  include Mongoid::Document
  include Mongoid::Timestamps

  field :date, type: Date
  field :comment, type: String

  embedded_in :user

end