def process_block(user_id, report_id)
  user_model = User.find(user_id)
  user_client = TwitterClient.user(user_model.auth)
  report = Report.find(report_id)

  # dont block users that our client user is following
  if user_client.friendship?(user_client, report.target.account_id.to_i)
    return
  end

  # dont block users that are already blocked
  if user_client.block?(report.target.account_id.to_i)
    return
  end

  # if the user does not want to block followers
  if user_model.dont_block_followers
    # dont block followers
    if user_client.friendship?(report.target.account_id.to_i, user_client)
      return
    end
  end

  # block
  user_client.block(report.target.account_id.to_i)
  block = Block.create(
    user: user_model,
    target: report.target,
    report: report,
  )

end
