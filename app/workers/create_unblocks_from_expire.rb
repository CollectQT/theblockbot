class CreateUnblocksFromExpire
  include Sidekiq::Worker
  sidekiq_options queue: 'unblocks'

  def perform

    for block in Block.expired
      user = block.user
      block.report.update_attributes(expired: true)

      # if user doesn't allow blocks to expire
      if not user.let_expire
        next
      end

      # unblock
      PostUnblock.perform_async(user.id, block.target.account_id.to_i, block.id)
      user.update_log("[REMOVE] Unblocking user #{block.target.user_name}")
    end

    # queue the next round
    CreateUnblocksFromExpire.perform_in 1.hours

  end

end
