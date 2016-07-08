class PostUnblock
  include MetaTwitter
  include Sidekiq::Worker

  sidekiq_retry_in do |count|
    # 15min * 60sec/min = 900sec
    900 * (count + 1)
  end

  def perform(user_database_id, target_twitter_id, block_id)
    user = get_user(user_database_id)

    user.unblock(target_twitter_id)
    Block.find(block_id).delete
  end

end
