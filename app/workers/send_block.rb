# from https://github.com/resque/resque#overview
class SendBlock
  include Sidekiq::Worker

  def perform(report_id, approver_id)
    report = Report.find(report_id)
    report.target.times_blocked += 1
    report.target.save

    for user_model in report.block_list.users
      user_client = Twitter::REST::Client.new do |config|
        config.consumer_key        = TwitterClient.REST.consumer_key
        config.consumer_secret     = TwitterClient.REST.consumer_secret
        config.access_token        = user_model.auth.key
        config.access_token_secret = user_model.auth.secret
      end

      # dont block users that our client user is following
      if user_client.friendship?(user_client, report.target.account_id.to_i)
        next
      else
        user_client.block(report.target.account_id.to_i)
        Block.create(
          user: user_model,
          target: report.target,
          reporter: report.reporter,
          text: report.text,
          block_list: report.block_list,
          approver_id: approver_id,
          report: report,
        )
      end
    end
    report.update_attributes(processed: true)
  end

end
