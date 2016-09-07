class CreateBlockStandalone
  include Sidekiq::Worker

  def perform(user_database_id, target_account_id)
    user_model = User.find(user_database_id)
    user_auth  = MetaTwitter::Auth.config(user_model)

    # dont block users that our client user is following
    MetaTwitter.get_following?(user_auth, target_account_id) ? return : nil

    # dont block users that are already blocked
    MetaTwitter.get_blocked?(user_auth, target_account_id) ? return : nil

    # if the user does not want to block followers...
    if user_model.dont_block_followers
      # ...then dont block followers
      MetaTwitter.get_follower?(user_auth, target_account_id) ? return : nil
    end

    PostBlockStandalone.perform_async(user_database_id, target_account_id)
  end
end
