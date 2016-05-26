class ReadFriendsOrFollowers

  def read(type, user_id)
    Rails.cache.fetch("fof/all/#{type}/#{user_id}", expires_in: 1.days) do
      cursor = -1
      fof_all = []

      if ['following', 'followers', 'friends'].include? type
        while cursor != 0
          fof_page, cursor = ReadFriendsOrFollowersPage.new.page(type, user_id, cursor)
          fof_all += fof_page
        end
      end

      return fof_all

    end
  end

  def page(type, user_id, cursor)
    Rails.cache.fetch("fof/page/#{type}/#{user_id}/#{cursor}", expires_in: 1.days) do
      user = TwitterClient.user(User.find(user_id))

      if type == 'followers'
        response = user.follower_ids(:cursor => cursor)
      elsif type == 'following' or type == 'friends'
        response = user.friend_ids(:cursor => cursor)
      end

      fof_page = response.to_a
      cursor = response.to_h[:next_cursor]

      return fof_page, cursor

    end
  rescue Twitter::Error::TooManyRequests => error
    sleep error.rate_limit.reset_in + 1
    retry
  end

end
