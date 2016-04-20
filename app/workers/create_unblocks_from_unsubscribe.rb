class CreateUnblocksFromUnsubscribe
  include Sidekiq::Worker

  def perform(user_id, block_list_id)
    for block in Block.where(user_id: user_id, block_list_id: block_list_id)
      Unblock.perform_async(user_id, block.target.account_id.to_i, block.id)
    end
  end

end
