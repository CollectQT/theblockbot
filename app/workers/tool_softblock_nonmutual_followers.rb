class ToolSoftblockNonmutualFollowers
  include Sidekiq::Worker

  def perform(user_id)
    followers = ReadFriendsOfFollowers('followers', user_id)
  end

end
