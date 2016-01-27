class SubscribeTo
  include Sidekiq::Worker

  def perform(user_id, block_list_id)
    Subscription.create(user_id: user_id, block_list_id: block_list_id)

    for report in Report.where(approved: true, expired: false, block_list_id: block_list_id)
      CreateBlock.perform_async(user_id, report.id)
    end

  end

end
