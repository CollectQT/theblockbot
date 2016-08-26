require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsApp
  class Application < Rails::Application

    config.autoload_paths << "#{Rails.root}/lib"

    config.cache_store = :redis_store, "redis://localhost:6379/0/cache", { expires_in: 1.days }

    config.middleware.use Rack::Attack

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.generators.test_framework(false)

    config.after_initialize do
      if Rails.env.development?
        begin
          require 'Sidekiq/api'
          Sidekiq::Queue.new('unblocks').clear
          Sidekiq::ScheduledSet.new.select \
            { |job| job.klass == 'CreateUnblocksFromExpire' }.each(&:delete)
          CreateUnblocksFromExpire.perform_async
        rescue LoadError
        end
      end
    end

  end
end
