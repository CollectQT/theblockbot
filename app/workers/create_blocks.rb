require 'process_block'

class CreateBlocks
  include Sidekiq::Worker

  def perform(report_id)
    report = Report.find(report_id)
    for user in report.block_list.users
      process_block(user.id, report.id)
    end
  end

end
