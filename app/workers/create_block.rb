class CreateBlock
  include MetaTwitter
  include Sidekiq::Worker

  def perform(user_database_id, report_id)
    user = get_user(user_database_id)
    report = Report.find(report_id)
    target = report.target.account_id.to_i

    # dont block users that our client user is following
    get_following?(user, target) ? return : nil

    # dont block users that are already blocked
    get_blocked?(user, target) ? return : nil

    # if the user does not want to block followers...
    if user.dont_block_followers
      # ...then dont block followers
      get_follower?(user, target) ? return : nil
    end

    PostBlock.perform_async(user.id, report.id)
  end
end
