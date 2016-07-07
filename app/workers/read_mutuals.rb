class ReadMutuals


  def from_following(user_id)
    read(user_id, "following")
  end


  def from_followers(user_id)
    read(user_id, "followers")
  end


  def read(user_id, type)
    Rails.cache.fetch("readmutuals/all/#{user_id}/#{type}", expires_in: 1.weeks) do
      user = get_user(user_id)
      target_users = friends_or_followers(user_id, type)
      page(user, type, target_users)
    end
  end


  private def friends_or_followers(user_id, type)
    ReadFriendsOrFollowers.new.read(user_id, type)
  end


  private def page(user, type, target_users, mutuals: [], nonmutuals: [], depth: 0, count: 100)
    Rails.cache.fetch("readmutuals/page/#{user.user.id}/#{type}/#{depth}", expires_in: 1.weeks) do

      puts "readmutuals/page/#{user.user.id}/#{type}/#{depth}"
      puts "target users #{target_users.length}"
      puts "mutuals #{mutuals.length}"
      puts "nonmutuals #{nonmutuals.length}"

      if target_users.length > 0

        _mutuals, _nonmutuals = process_page(user, target_users.take(count))

        target_users = target_users.drop(count)
        mutuals      = mutuals + _mutuals
        nonmutuals   = nonmutuals + _nonmutuals
        depth        = depth + 1

        page(user, type, target_users,
          mutuals: mutuals,
          nonmutuals: nonmutuals,
          depth: depth,
          count: count,
        )

      else
        return mutuals, nonmutuals

      end
    end
  end


  private def process_page(user, target_users)
    response = get_friendships(user, target_users)
    mutuals = []
    nonmutuals = []

    for item in response
      connections = item.connections

      if connections.include? "following" and connections.include? "followed_by"
        mutuals.concat([item.id])
      else
        nonmutuals.concat([item.id])
      end
    end

    return mutuals, nonmutuals
  end


  private def get_user(user_id)
    TwitterClient.user(User.find(user_id))
  rescue Twitter::Error::TooManyRequests => error
    sleep error.rate_limit.reset_in + 1
    retry
  end


  private def get_friendships(user, target_users)
    user.friendships(target_users)
  rescue Twitter::Error::TooManyRequests => error
    sleep error.rate_limit.reset_in + 1
    retry
  end

end
