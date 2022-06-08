require 'airbrake/sidekiq'

if Rails.env.production?
  redis_url = 'redis://10.135.6.37:6379/0'
else
  redis_url = 'redis://redis:6379/12'
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
