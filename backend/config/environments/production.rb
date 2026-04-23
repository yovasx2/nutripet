require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]

  # Allow any host since Traefik handles routing
  config.hosts << /.*/ if ENV["RAILS_ENV"] == "production"

  # ActionMailer config
  config.action_mailer.default_url_options = { host: ENV.fetch("DOMAIN", "localhost") }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false

  if ENV["SMTP_ADDRESS"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:              ENV["SMTP_ADDRESS"],
      port:                 ENV.fetch("SMTP_PORT", 587),
      domain:               ENV.fetch("SMTP_DOMAIN", ENV.fetch("DOMAIN", "localhost")),
      user_name:            ENV["SMTP_USERNAME"],
      password:             ENV["SMTP_PASSWORD"],
      authentication:       ENV.fetch("SMTP_AUTHENTICATION", "plain"),
      enable_starttls_auto: ENV.fetch("SMTP_TLS", "true") == "true"
    }
  else
    config.action_mailer.delivery_method = :test
  end
end
