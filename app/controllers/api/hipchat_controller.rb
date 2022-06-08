class Api::HipchatController < Api::ApiController

  before_action :authorize_trusted!, only: :history

  def history
    @messages = HipchatMessage.ordered_by_date

    render json: @messages.to_json
  end

  def callback
    @message = HipchatMessage.validate_and_create(message_params)

    head :ok
  end

  private

  def message_params
    params.require(:item).require(:message)
  end

end
