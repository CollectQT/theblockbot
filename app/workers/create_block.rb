class CreateBlock
  include MetaTwitter
  include Sidekiq::Worker

  def perform(user_id, report_id)
    user_model = User.find(user_id)
    user_client = get_user(user_model.id)
    report = Report.find(report_id)
    target = report.target.account_id.to_i

    # dont block users that our client user is following
    get_following?(user_client, target) ? return : nil

    # dont block users that are already blocked
    get_blocked?(user_client, target) ? return : nil

    # if the user does not want to block followers...
    if user.dont_block_followers
      # ...then dont block followers
      get_follower?(user_client, target) ? return : nil
    end

    PostBlock.perform_async(user.id, report.id)
    user_model.update_log("[ADD] Blocking user #{report.target.user_name}")
  end
end
