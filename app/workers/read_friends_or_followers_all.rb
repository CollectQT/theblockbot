class ReadFriendsOrFollowersAll

  def read(type, user_id)
    Rails.cache.fetch("fof/all/#{type}/#{user_id}", expires_in: 1.days) do
      cursor = -1
      fof_all = []

      if ['following', 'followers', 'friends'].include? type
        while cursor != 0
          fof_page, cursor = ReadFriendsOrFollowersPage.new.read(type, user_id, cursor)
          fof_all += fof_page
        end
      end

      return fof_all

    end
  end
end
