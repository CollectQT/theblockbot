class ToolBlockChain
  include Sidekiq::Worker

  def perform(user_database_id, target_account_name)
    # create a user for the target, for reference purposes
    User.get_from_twitter_name(target_account_name)

    user      = MetaTwitter::Auth.config( User.find(user_database_id) )
    followers = MetaTwitter::ReadFollows.from_followers( user, target: target_account_name )

    followers_without_following = MetaTwitter.remove_following_from_list(user, followers)

    for follower in followers
      puts "Blocking #{follower}"
      CreateBlock.perform_async(user_database_id, follower)
    end

  end
end
