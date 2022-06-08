# use the production settings
require File.expand_path('../production.rb', __FILE__)

Rails.application.configure do
  # Here override any defaults
  config.serve_static_files = true
  config.action_mailer.delivery_method = :letter_opener_web
  config.action_controller.asset_host = 'https://masters.mocstage.com/'
  config.action_mailer.asset_host = 'https://masters.mocstage.com/'
  config.action_mailer.default_url_options = { :host => 'mm.mocstage.com' }
end
