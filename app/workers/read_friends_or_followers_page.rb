class ReadFriendsOrFollowersPage

  def read(type, user_id, cursor)
    Rails.cache.fetch("fof/page/#{type}/#{user_id}/#{cursor}", expires_in: 1.days) do
      user = TwitterClient.user(User.find(user_id))

      if type == 'followers'
        response = user.follower_ids(:cursor => cursor, :count => 1000)
      elsif type == 'following' or type == 'friends'
        response = user.friend_ids(:cursor => cursor)
      end

      fof_page = response.to_a
      cursor = response.to_h[:next_cursor]

      return fof_page, cursor

    end
  end

end
