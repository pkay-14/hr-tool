class TrustedService

  def self.authorize!(token, mode)
    if mode == 'common'
      token == Rails.application.secrets[:api_common_token]
    else
      token == Rails.application.secrets[:api_token]
    end
  end

end