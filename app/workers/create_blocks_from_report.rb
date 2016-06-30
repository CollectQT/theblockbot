class CreateBlocksFromReport
  include Sidekiq::Worker

  def perform(report_id)
    report = Report.find(report_id)
    work(report)
  end

  def work(report)
    for user in report.block_list.users
      block(user, report)
    end
  end

  private def block(user, report)
    CreateBlock.perform_async(user.id, report.id)
  end

end
