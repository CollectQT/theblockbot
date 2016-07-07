class ReadFriendsOrFollowers


  def followers(user_id)
    read(user_id, "followers")
  end


  def following(user_id)
    read(user_id, "following")
  end


  def read(user_id, type)
    Rails.cache.fetch("fof/all/#{user_id}/#{type}", expires_in: 1.weeks) do
      user = TwitterClient.user(User.find(user_id))
      fof = page(user, type)
    end
  rescue Twitter::Error::TooManyRequests => error
    sleep error.rate_limit.reset_in + 1
    retry
  end


  private def page(user, type, fof: [], cursor: -1)
    Rails.cache.fetch("fof/page/#{user.user.id}/#{type}/#{cursor}", expires_in: 1.weeks) do

      if cursor != 0
        response = process_page(user, type, fof, cursor)
        page(user, type,
          fof: fof + response.to_a,
          cursor: response.to_h[:next_cursor],
        )
      else
        return fof
      end

    end
  end


  private def process_page(user, type, fof, cursor, count: 5000)

      if type == 'followers'
        user.follower_ids(:cursor => cursor, :count => count)
      elsif type == 'following'
        user.friend_ids(:cursor => cursor, :count => count)
      end

  rescue Twitter::Error::TooManyRequests => error
    sleep error.rate_limit.reset_in + 1
    retry
  end


end
