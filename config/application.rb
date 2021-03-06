# require File.expand_path('../boot', __FILE__)
require_relative 'boot'

#require 'rails/all'
# require "bson"
# require "moped"
require "net/http"

# Pick the frameworks you want:
# require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"


# Moped::BSON = BSON
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HrModule
  class Application < Rails::Application
    config.middleware.delete Rack::Lock
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.eager_load_paths += %W(#{config.root}/lib)
    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.eager_load_paths += Dir[Rails.root.join('app', 'api', '*')]
    config.generators do |g|
      g.javascript_engine :js
      g.orm :active_record
      # g.orm :mongoid
    end
  end
end
