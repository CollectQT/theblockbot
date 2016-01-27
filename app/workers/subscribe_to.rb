require 'process_block'

class SubscribeTo
  include Sidekiq::Worker

  def perform(user_id, block_list_id)
    Subscription.create(user_id: user_id, block_list_id: block_list_id)

    for report in Report.where(approved: true, expired: false, block_list_id: block_list_id)
      process_block(user_id: user_id, report_id: report.id)
    end

  end

end
