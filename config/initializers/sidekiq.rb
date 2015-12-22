# looks the following in secrets.yml
#
# development:
#   REDIS_URL: XXXXXXXXXXXXXXXXXXXXXXXXXXX

Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.secrets.REDIS_URL }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.secrets.REDIS_URL }
end
