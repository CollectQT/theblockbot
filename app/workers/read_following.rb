class ReadFollowing
  include Sidekiq::Worker

  def perform(user_id, target_id)
    Rails.cache.fetch("#{user_id}/#{target_id}/following", expires_in: 1.days) do
      user = TwitterClient.user(User.find(user_id))
      return user.friendship?(user, target_id)
    end
  end

end
