class SendBlock
  include Sidekiq::Worker

  def perform(report_id, approver_id)

    report = Report.find(report_id)
    report.update_attributes(approver_id: approver_id)
    report.target.increment(:times_blocked)
    report.reporter.increment(:reports_approved)

    for user_model in report.block_list.users
      user_client = TwitterClient.user(user_model.auth)

      # dont block users that our client user is following
      if user_client.friendship?(user_client, report.target.account_id.to_i)
        next
      else
        user_client.block(report.target.account_id.to_i)
        Block.create(
          user: user_model,
          target: report.target,
          report: report,
        )
      end
    end

    report.update_attributes(processed: true)

  end

end
