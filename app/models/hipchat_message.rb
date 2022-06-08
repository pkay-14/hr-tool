class HipchatMessage
  include Mongoid::Document

  field :user_name
  field :body
  field :date

  scope :ordered_by_date, -> { order(date: :desc) }

  def self.validate_and_create(message_params)
    if message_params[:message].include?('@all')
      self.create(
          user_name: message_params[:from][:name],
          body: message_params[:message],
          date: message_params[:date]
      )
    end
  end

end
