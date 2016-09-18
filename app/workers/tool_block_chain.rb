class ToolBlockChain
  include Sidekiq::Worker

  def perform(user_database_id, target_account_name)
    # create a user for the target, for reference purposes
    target_account_id = User.get_from_twitter_name(target_account_name).account_id

    user        = MetaTwitter::Auth.config( User.find(user_database_id) )
    target_list = MetaTwitter::ReadFollows.from_followers( user, target: target_account_name )

    target_list = MetaTwitter.remove_follow_from_list(user, target_list, "following")
    target_list = MetaTwitter.remove_blocked_from_list(user, target_list)
    # a filter for removing followers is purposefully omitted here

    for follower in followers
      CreateBlock.perform_async(user_database_id, follower)
    end

  end
end
