require 'process_block'

class ApproveBlock
  include Sidekiq::Worker

  def perform(report_id, approver_id)

    report = Report.find(report_id)
    approver = User.find(approver_id)

    unless approver.in? report.block_list.blockers
      puts 'User(#{approver_id}) Not Authorized to approve Report(#{report_id})'
      return
    end

    for user_model in report.block_list.users
      process_block(user_id: user_id, report_id: report_id)
    end

    report.update_attributes(approver: approver, approved: true, processed: true)
    report.target.increment(:times_blocked)
    report.reporter.increment(:reports_approved)

  end

end
