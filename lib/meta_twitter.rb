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


############################################


module MetaTwitter

  def get_id(user)
  # user => Twitter::REST::Client (with user context auth)
    user.access_token.split('-')[0]
  end

  # TODO phase this out
  rate_limit_rescue def get_user(user_id)
  # user_id => User.id
    TwitterClient.user(User.find(user_id))
  end

  rate_limit_rescue def create_user_from_db_id(user_id)
  # user_id => User.id
    TwitterClient.user(User.find(user_id))
  end

  rate_limit_rescue def read_user_from_twitter_name(id)
  # id => int or string (ex '@cyrin')
    TwitterClient.REST.user(id)
  end

  rate_limit_rescue def get_following?(user, target_id)
  # user => Twitter::REST::Client (with user context auth)
  # target_id => int
    Rails.cache.fetch("#{get_id(user)}/following?/#{target_id}", expires_in: 1.days) do
      user.friendship?(user, target_id)
    end
  end

  rate_limit_rescue def get_following_ids(user, cursor, count)
  # user => Twitter::REST::Client (with user context auth)
  # cursor => int
  # count => int
    Rails.cache.fetch("#{get_id(user)}/all_following/#{cursor}", expires_in: 1.weeks) do
      user.friend_ids(:cursor => cursor, :count => count)
    end
  end

  rate_limit_rescue def get_follower?(user, target_id)
  # user => Twitter::REST::Client (with user context auth)
  # target_id => int
    Rails.cache.fetch("#{get_id(user)}/follower?/#{target_id}", expires_in: 1.days) do
      user.friendship?(target_id, user)
    end
  end

  rate_limit_rescue def get_follower_ids(user, cursor, count)
  # user => Twitter::REST::Client (with user context auth)
  # cursor => int
  # count => int
    Rails.cache.fetch("#{get_id(user)}/all_followers/#{cursor}", expires_in: 1.weeks) do
      user.follower_ids(:cursor => cursor, :count => count)
    end
  end

  rate_limit_rescue def get_blocked?(user, target_id)
  # user => Twitter::REST::Client (with user context auth)
  # target_id => int
    Rails.cache.fetch("#{get_id(user)}/blocked?/#{target_id}", expires_in: 1.days) do
      user.friendship?(target_id, user)
    end
  end

  rate_limit_rescue def get_connections(user, target_users)
  # user => Twitter::REST::Client (with user context auth)
  # target_users => [Twitter.user.id,]
    user.friendships(target_users)
  end

  ############################################

  class ReadAllFollows

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
      Rails.cache.fetch("fof/page/#{get_id(user)}/#{type}/#{cursor}", expires_in: 1.weeks) do
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
        response = get_following_ids(user, cursor, count)
      end
      fof = fof + response.to_a
      cursor = response.to_h[:next_cursor]
      return fof, cursor
    end

  end

  ############################################

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
        target_users = ReadAllFollows.new.read(user_id, type)
        page(user, type, target_users)
      end
    end

    private def page(user, type, target_users, mutuals: [], nonmutuals: [], depth: 0, count: 100)
      Rails.cache.fetch("readmutuals/page/#{get_id(user)}/#{type}/#{depth}", expires_in: 1.weeks) do

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
      response = get_connections(user, target_users)
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

  end

end
