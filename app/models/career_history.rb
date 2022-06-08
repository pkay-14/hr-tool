class CareerHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  field :position, type: String
  field :community, type: String
  field :company_division, type: String
  field :start_date, type: Date
  field :end_date, type: Date
  field :dismissed, type: Boolean, default: false

  belongs_to :master, class_name: 'User'

  scope :recent_first, -> { order_by(created_at: :desc) }

  def beginning_date
    start_date = self.start_date.present? ? self.start_date&.strftime('%d.%m.%Y') : self.master.hired_at&.strftime('%d.%m.%Y')
    start_date.blank? ? 'undefined' : start_date
  end

  def finish_date
    if self.master.is_left? && self.end_date.blank?
      self.end_date = self.master.left_at
      self.save
      self.end_date&.strftime('%d.%m.%Y')
    else
      self.end_date.present? ? self.end_date&.strftime('%d.%m.%Y') : "Now"
    end
  end

  def previous_date
    return start_date unless dismissed

    end_date
  end
end
