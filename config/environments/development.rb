Rails.application.configure do
  config.cache_classes = false
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.public_file_server.enabled = true
end

