class UnblockProcessor
  include Sidekiq::Worker

  def perform

    for block in Block.where('expires < ?', DateTime.now).where.not(expires: nil)
      user = block.user
      block.report.update_attributes(expired: true)

      # if user doesn't allow blocks to expire
      if not user.let_expire
        next
      end

      # unblock
      Unblock.perform_async(user.id, block.target.account_id.to_i, block.id)
    end

  end

end
