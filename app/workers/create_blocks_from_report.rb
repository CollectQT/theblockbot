class CreateBlocksFromReport
  include Sidekiq::Worker

  def perform(report_id)
    work_on(Report.find(report_id))
  end

  def work_on(report)
    for user in report.block_list.users
      block(user.id, report.id)
    end
  end

  private def block(user_id, report)
    CreateBlock.perform_async(user_id, report)
  end

end
