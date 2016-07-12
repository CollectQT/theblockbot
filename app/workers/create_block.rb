class CreateBlock
  include Sidekiq::Worker

  def perform(user_database_id, report_id)
    user = MetaTwitter.get_user(user_database_id)
    report = Report.find(report_id)
    target = report.target.account_id.to_i

    # dont block users that our client user is following
    MetaTwitter.get_following?(user, target) ? return : nil

    # dont block users that are already blocked
    MetaTwitter.get_blocked?(user, target) ? return : nil

    # if the user does not want to block followers...
    if user.dont_block_followers
      # ...then dont block followers
      MetaTwitter.get_follower?(user, target) ? return : nil
    end

    PostBlock.perform_async(user.id, report.id)
  end
end
