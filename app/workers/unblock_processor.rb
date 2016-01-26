class UnblockProcessor
  include Sidekiq::Worker

  def perform

    for block in Block.where('expires < ?', DateTime.now).where.not(expires: nil)
      user_model = block.user
      user_client = TwitterClient.user(user_model.auth)
      block.report.update_attributes(expired: true)

      # expires
      if not user_model.let_expire
        next
      end

      # unblock
      user_client.unblock(target.account_id.to_i)
      block.delete
    end

  end

end
