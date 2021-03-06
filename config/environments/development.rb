Etm::Application.configure do

  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  # config.action_mailer.raise_delivery_errors = false

  config.action_controller.perform_caching = false
  #config.cache_store = :memory_store
  config.cache_store = :dalli_store
  #config.cache_store = :file_store, '/tmp/cache'
  config.assets.debug = true

  config.eager_load = false
end
