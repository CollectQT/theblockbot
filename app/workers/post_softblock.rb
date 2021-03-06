class PostSoftblock
  include Sidekiq::Worker

  sidekiq_retry_in do |count|
    # 15min * 60sec/min = 900sec
    900 * (count + 1)
  end

  def perform(user_database_id, target_twitter_id)
    user = MetaTwitter::Auth.config( User.find(user_database_id) )

    user.block(target_twitter_id)
    user.unblock(target_twitter_id)
  end

end
