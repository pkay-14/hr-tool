Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.after_initialize do
    Bullet.enable        = true
    # Bullet.alert         = false
    Bullet.bullet_logger = true
    # Bullet.console       = true
    # Bullet.add_footer    = true
  end

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false

  config.action_mailer.asset_host = "http://localhost:8080"
  config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log
  # config.action_controller.perform_caching = false

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true
  config.public_file_server.enabled = true

  config.assets.check_precompiled_asset = false
  config.serve_static_files = true
  ENV['mandrill_api_secret'] = 'B2NpJM8X1ImZBy-qHirOXw'
  # config.action_mailer.delivery_method = :smtp
  # smtp_creds = Rails.application.secrets.smtp
  # config.action_mailer.smtp_settings = {
  #   :user_name => smtp_creds[:user_name],
  #   :password => smtp_creds[:password],
  #   :address => smtp_creds[:address],
  #   :domain => smtp_creds[:domain],
  #   :port => smtp_creds[:port],
  #   :authentication => smtp_creds[:authentication]
  # }
  config.action_mailer.delivery_method = :letter_opener_web
  config.action_mailer.perform_deliveries = true #try to force sending in development
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.default_url_options = { host: 'mm.mocintra.local:8080' }

  ActionMailer::Base.delivery_method = :smtp

  #ADD YOUR DESCRIPTOR TO facility FIELD BELOW
  #config.logger = GELF::Logger.new("logserver.mocstage.com", 12219, "WAN", { :facility => "HRDEV.BOGDAN.SERGIIENKO" })
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::KeyValue.new

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,

  # routes, locales, etc. This feature depends on the listen gem.

  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

end
