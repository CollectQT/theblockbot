namespace :sidekiq do
  desc "Clears out old instances of the unblock worker, starts a new one"
  task unblock_worker: :environment do
    require 'Sidekiq/api'
    Sidekiq::Queue.new('unblocks').clear
    Sidekiq::ScheduledSet.new.select \
      { |job| job.klass == 'CreateUnblocksFromExpire' }.each(&:delete)
    CreateUnblocksFromExpire.perform_async
  end
end
