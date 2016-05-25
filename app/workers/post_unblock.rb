class PostUnblock
  include Sidekiq::Worker

  sidekiq_retry_in do |count|
    # 15min * 60sec/min = 900sec
    900 * (count + 1)
  end

  def perform(user_id, target_id, block_id)
    TwitterClient.user(User.find(user_id)).unblock(target_id)
    Block.find(block_id).delete
  end

end
