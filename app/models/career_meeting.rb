class CareerMeeting
  include Mongoid::Document
  include Mongoid::Timestamps

  field :comment, type: String
  field :visible_by_managers, type: Boolean
  field :date, type: Date

  belongs_to :master, class_name: 'User'

end
