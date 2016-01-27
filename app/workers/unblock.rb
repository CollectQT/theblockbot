class Unblock
  include Sidekiq::Worker

  def perform(user_id, target_account_id, block_id)
    auth = User.find(user_id).auth
    user = TwitterClient.user(auth)
    user.unblock(target_id)
    Block.find(block_id).delete
  end

end
