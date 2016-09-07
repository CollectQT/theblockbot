class CreateBlockStandalone
  include Sidekiq::Worker

  def perform(user_database_id, target_account_id)
    user = MetaTwitter::Auth.config( User.find(user_database_id) )

    # dont block users that our client user is following
    MetaTwitter.get_following?(user, target) ? return : nil

    # dont block users that are already blocked
    MetaTwitter.get_blocked?(user, target) ? return : nil

    # if the user does not want to block followers...
    if user.dont_block_followers
      # ...then dont block followers
      MetaTwitter.get_follower?(user, target) ? return : nil
    end

    PostBlockStandalone.perform_async(user_database_id, target_account_id)
  end
end
