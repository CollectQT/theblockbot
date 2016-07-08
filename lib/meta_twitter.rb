def rate_limit_rescue(name)
  m = instance_method(name)
  define_method(name) do |*args|
    begin
      m.bind(self).call(*args)
    rescue Twitter::Error::TooManyRequests => error
      tries ||= 0
      tries += 1
      if tries < 6
        sleep error.rate_limit.reset_in + tries + 1
        retry
      else
        raise
      end
    end
  end
end


module MetaTwitter

  rate_limit_rescue def get_user(user_id)
  # user_id => User.id
    TwitterClient.user(User.find(user_id))
  end

  rate_limit_rescue def get_following?(user, target_id)
  # user => Twitter::REST::Client (with user context auth)
  # target_id => int
    Rails.cache.fetch("#{user.user.id}/#{target_id}/following", expires_in: 1.days) do
      user.friendship?(user, target_id)
    end
  end

  rate_limit_rescue def get_following_ids(user, cursor, count)
  # user => Twitter::REST::Client (with user context auth)
  # cursor => int
  # count => int
    Rails.cache.fetch("#{user.user.id}/#{target_id}/follower", expires_in: 1.days) do
      user.friend_ids(:cursor => cursor, :count => count)
    end
  end

  rate_limit_rescue def get_follower?(user, target_id)
  # user => Twitter::REST::Client (with user context auth)
  # target_id => int
    Rails.cache.fetch("#{user.user.id}/#{target_id}/follower", expires_in: 1.days) do
      user.friendship?(target_id, user)
    end
  end

  rate_limit_rescue def get_follower_ids(user, cursor, count)
  # user => Twitter::REST::Client (with user context auth)
  # cursor => int
  # count => int
    Rails.cache.fetch("#{user.user.id}/#{target_id}/follower", expires_in: 1.days) do
      user.follower_ids(:cursor => cursor, :count => count)
    end
  end

  rate_limit_rescue def get_blocked?(user, target_id)
  # user => Twitter::REST::Client (with user context auth)
  # target_id => int
    Rails.cache.fetch("#{user.user.id}/#{target_id}/follower", expires_in: 1.days) do
      user.friendship?(target_id, user)
    end
  end

end
