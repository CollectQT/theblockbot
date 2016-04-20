class PostUnblock
  include Sidekiq::Worker

  def perform(user_id, target_id, block_id)
    TwitterClient.user(User.find(user_id)).unblock(target_id)
    Block.find(block_id).delete
  end

end
