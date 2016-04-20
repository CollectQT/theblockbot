class ReadFollower
  include Sidekiq::Worker

  def perform(user_id, target_id)
    Rails.cache.fetch("#{user_id}/#{target_id}/follower", expires_in: 1.days) do
      user = TwitterClient.user(User.find(user_id))
      return user.friendship?(target_id, user)
    end
  end

end
