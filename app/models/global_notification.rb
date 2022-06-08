class GlobalNotification
  include Mongoid::Document
  include Mongoid::Paperclip

  field :title
  field :body
  field :category, type: Integer, default: 0
  field :date, type: Date

  CATEGORIES = {
      1 => 'Help',
      2 => 'New master',
      3 => 'New event',
      4 => "What's new"
  }

  has_mongoid_attached_file :image
  validates_attachment_content_type :image, :content_type => %w(image/jpg image/jpeg image/png image/gif)

  before_save :set_date

  # TODO: after save send notifications to attached devices (get device_tokens from moc_id endpoint )

  def set_date
    self.date = Date.today
  end

end
