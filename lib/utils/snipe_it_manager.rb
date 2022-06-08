module Utils
  class SnipeItManager
    include HTTParty

    base_uri Rails.application.secrets[:snipe_it_base_url]

    attr_accessor :moc_email, :user_id

    def initialize(moc_email)
      self.moc_email = moc_email
    end

    def user
      self.class.get("/users?email=#{moc_email}", options).parsed_response
    end

    def user_hardwares
      user_assets + user_accessories
    end

    def user_assets
      response = self.class.get("/users/#{get_user_id}/assets", options).parsed_response
      assets = response['rows']&.map do |row|
        {category: row.dig('category','name'), name: row.dig('name'), tag: row.dig('asset_tag')}
      end
      assets.present? ? assets : []
    end

    def user_accessories
      response = self.class.get("/users/#{get_user_id}/accessories", options).parsed_response
      accessories = response['rows']&.map do |row|
        {category: row.dig('name'), name: "#{row.dig('manufacturer', 'name')} #{row.dig('model_number')}"}
      end
      accessories.present? ? accessories : []
    end

    def get_user_id
      self.user_id ||= user.dig('rows',0,'id')
    end

    def options
      {
        headers: {'Content-Type' => 'application/json',
                  'Authorization' => "Bearer #{Rails.application.secrets[:snipe_it_token]}"},
        verify: false
      }
    end

  end
end
