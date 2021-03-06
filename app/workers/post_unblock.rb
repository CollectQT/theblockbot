class PostUnblock
  include Sidekiq::Worker

  sidekiq_retry_in do |count|
    # 15min * 60sec/min = 900sec
    900 * (count + 1)
  end

  def perform(user_database_id, target_twitter_id, block_id: nil)
    user = MetaTwitter::Auth.config( User.find(user_database_id) )

    begin
      user.unblock(target_twitter_id)
    rescue Twitter::Error::NotFound
      Rails.logger.info { "Twitter account with id #{target_twitter_id} no longer exists" }
    end

    if block_id then Block.find(block_id).delete end
  end

end
