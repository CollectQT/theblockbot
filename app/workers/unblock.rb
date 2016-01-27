class Unblock
  include Sidekiq::Worker

  def perform(user_id, target_account_id, block_id)
    user_model = User.find(user_id)
    user_client = TwitterClient.user(user_model.auth)

    user_client.unblock(target_account_id)
    block = Block.find(block_id)
    user_model.update_log("[REMOVE] Unblocked user #{block.target.user_name}")
    block.delete
  end

end
