class ReadFollower

  def read(user_id, target_id)
    Rails.cache.fetch("#{user_id}/#{target_id}/follower", expires_in: 1.days) do
      user = TwitterClient.user(User.find(user_id))
      return user.friendship?(target_id, user)
    end
  rescue Twitter::Error::TooManyRequests => error
    sleep error.rate_limit.reset_in + 1
    retry
  end

end
