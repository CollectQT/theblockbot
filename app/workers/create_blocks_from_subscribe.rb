class CreateBlocksFromSubscribe
  include Sidekiq::Worker

  def perform(user_id, block_list_id)
    for report_id in Report.where(approved: true, expired: false, block_list_id: block_list_id).pluck(:id)
      CreateBlock.perform_async(user_id, report_id)
    end
  end

end
