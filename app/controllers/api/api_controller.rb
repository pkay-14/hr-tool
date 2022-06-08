class Api::ApiController < ApplicationController

  skip_before_action :verify_authenticity_token
  skip_before_action :check_subdomain

  protected

  def authorize_trusted!(mode = 'normal')
    render json: {error: 'wrong api_token!'}.to_json, status: 401 unless TrustedService.authorize!(request.headers["API-Token"], mode)
  end

end
