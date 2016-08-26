namespace :sidekiq do
  desc "Clears out old instances of the unblock worker, starts a new one"
  task unblock_worker: :environment do
    CreateUnblocksFromExpire.perform_async
  end
end
