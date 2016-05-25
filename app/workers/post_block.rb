class PostBlock
  include Sidekiq::Worker

  sidekiq_retry_in do |count|
    # 15min * 60sec/min = 900sec
    900 * (count + 1)
  end

  def perform(user_id, report_id)
    user = TwitterClient.user(User.find(user_id))
    report = Report.find(report_id)

    user.block(report.target.account_id.to_i)

    Block.create(
      user: user,
      target: report.target,
      report: report,
      block_list: report.block_list,
    )
  end

end
