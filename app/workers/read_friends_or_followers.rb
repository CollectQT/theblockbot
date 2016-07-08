class ReadFriendsOrFollowers
  include MetaTwitter


  def followers(user_id)
    read(user_id, "followers")
  end


  def following(user_id)
    read(user_id, "following")
  end


  def read(user_id, type)
    Rails.cache.fetch("fof/all/#{user_id}/#{type}", expires_in: 1.weeks) do
      user = get_user(user_id)
      fof = page(user, type)
    end
  end


  private def page(user, type, fof: [], cursor: -1)
    Rails.cache.fetch("fof/page/#{user.user.id}/#{type}/#{cursor}", expires_in: 1.weeks) do

      if cursor != 0
        fof, cursor = process_page(user, type, fof, cursor)
        page(user, type, fof: fof, cursor: cursor)
      else
        fof
      end

    end
  end


  private def process_page(user, type, fof, cursor, count: 5000)
    if type == 'followers'
      response = get_follower_ids(user, cursor, count)
    elsif type == 'following'
      response = get_friend_ids(user, cursor, count)
    end
    fof = fof + response.to_a
    cursor = response.to_h[:next_cursor]

    return fof, cursor
  end


end
