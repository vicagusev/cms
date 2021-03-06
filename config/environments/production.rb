# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Force all environments to use the same logger level
# (by default production uses :info, the others :debug)
# config.log_level = Logger::ERROR
config.logger = Logger.new(config.log_path, 10, 5242880)
config.logger.level = Logger::WARN
# config.logger.level = Logger::DEBUG

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

config.cache_store = :mem_cache_store, '127.0.0.1:11211'
#config.cache_store = :file_store, "tmp/cache/"

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
