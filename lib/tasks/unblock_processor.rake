namespace :sidekiq do
  desc "Check the Block table for blocks that have expired"
  task unblock_processor: :environment do
    CreateUnblocksFromExpire.perform_async
    puts "Checking for expired blocks"
  end
end
