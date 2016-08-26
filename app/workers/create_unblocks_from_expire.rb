class CreateUnblocksFromExpire
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform

    for block in Block.expired
      user = block.user
      block.report.update_attributes(expired: true)

      next unless user.let_expire

      # unblock
      PostUnblock.perform_async(user.id, block.target.account_id.to_i, block.id)
      user.update_log("[REMOVE] Unblocking user #{block.target.user_name}")
    end

    # clear any previous running jobs
    Sidekiq::ScheduledSet.new.select \
      { |job| job.klass == self.class.name }.each(&:delete)

    # queue the next round
    CreateUnblocksFromExpire.perform_in 1.hours

  end

end
