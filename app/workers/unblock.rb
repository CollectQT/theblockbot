class Unblock
  include Sidekiq::Worker

  def perform(user_id, target_account_id, block_id)
    auth = User.find(user_id).auth
    user = TwitterClient.user(auth)
    user.unblock(target_account_id)
    block = Block.find(block_id)
    user.update_log("[REMOVE] Unblocked user #{block.target.user_name}")
    block.delete
  end

end
