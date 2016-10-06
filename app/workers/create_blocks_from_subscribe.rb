class CreateBlocksFromSubscribe
  include Sidekiq::Worker

  def perform(user_id, block_list_id)
    # work_on(user_id, BlockList.find(block_list_id))
  end

  # def work_on(user_id, block_list)
  #   for report in block_list.active_reports
  #     block(user_id, report.id)
  #   end
  # end

  # private def block(user_id, report)
  #   CreateBlock.perform_async(user_id, report)
  # end

end
