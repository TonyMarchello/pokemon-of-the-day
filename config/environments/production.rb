Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.log_level = :info

  # Render captures stdout/stderr, so send Rails logs there in production.
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new($stdout))
    logger.formatter = config.log_formatter
    config.logger = logger
  end
end
