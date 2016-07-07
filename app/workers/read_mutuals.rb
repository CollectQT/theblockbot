class ReadMutuals

  def from_following(user_id)
    read(user_id, "following")
  end

  def from_followers(user_id)
    read(user_id, "followers")
  end

  def read(user_id, type)
    Rails.cache.fetch("readmutuals/all/#{user_id}/#{type}", expires_in: 1.weeks) do
      target_users = friends_or_followers(user_id, type)
      page(user_id, type, target_users)
    end
  end

  private def page(user_id, type, target_users, mutuals: [], nonmutuals: [], depth: 0)
    Rails.cache.fetch("readmutuals/page/#{user_id}/#{type}/#{depth}", expires_in: 1.weeks) do
      if target_users.length > 0
        page( *process_page( user_id, type, target_users, mutuals, nonmutuals, depth) )
      else
        return mutuals, nonmutuals
      end
    end
  end

  private def process_page(user_id, type, target_users, mutuals, nonmutuals, depth, count: 100)
    _mutuals, _nonmutuals = lookup(user_id, target_users.take(count))

    target_users = target_users.drop(count)
    mutuals      = mutuals    + _mutuals
    nonmutuals   = nonmutuals + _nonmutuals
    depth        = depth + 1

    return user_id, type, target_users, mutuals, nonmutuals, depth
  end

  private def friends_or_followers(user_id, type)
    ReadFriendsOrFollowers.new.read(user_id, type)
  end

  private def lookup(user_id, target_users)
    PostRelationshipLookup.new.read(user_id, target_users)
  end

end
