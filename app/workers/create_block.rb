class CreateBlock
  include Sidekiq::Worker

  def perform(user_database_id, report_id)
    user_model = User.find(user_database_id)
    user_auth  = MetaTwitter::Auth.config(user_model)
    report = Report.find(report_id)
    target = report.target.account_id.to_i

    # dont block users that our client user is following
    MetaTwitter.get_following?(user_auth, target) ? return : nil

    # dont block users that are already blocked
    MetaTwitter.get_blocked?(user_auth, target) ? return : nil

    # if the user does not want to block followers...
    if user_model.dont_block_followers
      # ...then dont block followers
      MetaTwitter.get_follower?(user_auth, target) ? return : nil
    end

    PostBlock.perform_async(user_model.id, report.id)
  end
end
