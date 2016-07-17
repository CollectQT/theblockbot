def rescue_rate_limit
  yield
rescue Twitter::Error::TooManyRequests => error
  tries ||= 0
  tries += 1
  if tries < 6
    puts "[WARNING] Hit Twitter rate limit in lib/meta_twitter.rb, current retries: #{tries}/5"
    sleep error.rate_limit.reset_in + tries + 1
    retry
  else
    puts "[ERROR] Exhausted all rate limit retries in lib/meta_twitter.rb"
    raise
  end
end

def rescue_not_found
  yield
rescue Twitter::Error::NotFound
  nil
end


############################################


module MetaTwitter

  def MetaTwitter.strip_if_leading_character(string, character)
  # string -> string ('@cats' or '#cats' or 'cats')
  # character -> string ('#' or '@')
    string[0] == character ? string[1..string.length] : string
  end

  def MetaTwitter.get_account_id(user)
  # user => MetaTwitter::Auth.config
    user.access_token.split('-')[0]
  end

  def MetaTwitter.read_user_from_auth
    MetaTwitter.read_user_from_twitter_id(
      MetaTwitter.get_account_id(TwitterClient)
    )
  end

  def MetaTwitter.read_user_from_twitter_id(id)
  # id => int (1111111111111111)
    Rails.cache.fetch("/read_from_id/#{id}", expires_in: 1.hours) do
      rescue_not_found {
      rescue_rate_limit {
        TwitterClient.user(id.to_i).to_h
      }}
    end
  end

  def MetaTwitter.read_user_from_twitter_name(name)
  # name => string ('@cyrin')
    name = MetaTwitter.strip_if_leading_character(name, '@')
    Rails.cache.fetch("/read_from_name/#{name}", expires_in: 1.hours) do
      rescue_not_found {
      rescue_rate_limit {
        TwitterClient.user(name).to_h
      }}
    end
  end

  def MetaTwitter.read_users_from_ids(ids)
  # ids => array(int) ([111111,], max size: 100)
    key = Digest::MD5.hexdigest(ids.to_s)
    Rails.cache.fetch("/read_from_bulk_ids/#{key}", expires_in: 1.days) do
      rescue_not_found {
      rescue_rate_limit {
        users = TwitterClient.users(ids)
      }}
      users = (users).map { |user| user.to_h }
    end
  end

  ############################################

  def MetaTwitter.get_following?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    Rails.cache.fetch("#{MetaTwitter.get_account_id(user)}/following?/#{target_id}", expires_in: 1.weeks) do
      rescue_rate_limit {
        user.friendship?(user, target_id)
      }
    end
  end

  def MetaTwitter.get_following_ids(user, cursor, count)
  # user => MetaTwitter::Auth.config
  # cursor => int
  # count => int
    Rails.cache.fetch("#{MetaTwitter.get_account_id(user)}/all_following/#{cursor}", expires_in: 1.months) do
      rescue_rate_limit {
        user.friend_ids(:cursor => cursor, :count => count)
      }
    end
  end

  def MetaTwitter.get_follower?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    Rails.cache.fetch("#{MetaTwitter.get_account_id(user)}/follower?/#{target_id}", expires_in: 1.weeks) do
      rescue_rate_limit {
        user.friendship?(target_id, user)
      }
    end
  end

  def MetaTwitter.get_follower_ids(user, cursor, count)
  # user => MetaTwitter::Auth.config
  # cursor => int
  # count => int
    Rails.cache.fetch("#{MetaTwitter.get_account_id(user)}/all_followers/#{cursor}", expires_in: 1.months) do
      rescue_rate_limit {
        user.follower_ids(:cursor => cursor, :count => count)
      }
    end
  end

  def MetaTwitter.get_blocked?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    Rails.cache.fetch("#{MetaTwitter.get_account_id(user)}/blocked?/#{target_id}", expires_in: 1.weeks) do
      rescue_rate_limit {
        user.friendship?(target_id, user)
      }
    end
  end

  def MetaTwitter.get_connections(user, target_users)
  # user => MetaTwitter::Auth.config
  # target_users => [Twitter.user.id,] length <= 100
    rescue_rate_limit {
      user.friendships(target_users)
    }
  end

  ############################################

  # MetaTwitter::Auth.config(User)

  class Auth
    def self.config(user)
    # user -> User
      Twitter::REST::Client.new do |c|
        c.consumer_key        = TwitterClient.consumer_key
        c.consumer_secret     = TwitterClient.consumer_secret
        c.access_token        = user.token
        c.access_token_secret = user.secret
      end
    end

  end

  ############################################

  # MetaTwitter::ReadFollows.from_following( MetaTwitter::Auth.config( User.first ) )

  class ReadFollows

    def self.from_followers(user)
    # user => MetaTwitter::Auth.config
      self.read(user, "followers")
    end

    def self.from_following(user)
    # user => MetaTwitter::Auth.config
      self.read(user, "following")
    end

    def self.read(user, type)
    # user => MetaTwitter::Auth.config
    # type => string ("followers" or "following")
      Rails.cache.fetch("fof/all/#{MetaTwitter.get_account_id(user)}/#{type}", expires_in: 1.months) do
        self.new.page(user, type)
      end
    end

    def page(user, type, fof: [], cursor: -1)
      Rails.cache.fetch("fof/page/#{MetaTwitter.get_account_id(user)}/#{type}/#{cursor}", expires_in: 1.months) do
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
        response = MetaTwitter.get_follower_ids(user, cursor, count)
      elsif type == 'following'
        response = MetaTwitter.get_following_ids(user, cursor, count)
      end
      fof = fof + response.to_a
      cursor = response.to_h[:next_cursor]
      return fof, cursor
    end

  end

  ############################################

  # MetaTwitter::ReadMutuals.from_following( MetaTwitter::Auth.config( User.first ) )

  class ReadMutuals

    def self.from_following(user)
    # user => MetaTwitter::Auth.config
      read(user, "following")
    end

    def self.from_followers(user)
    # user => MetaTwitter::Auth.config
      self.read(user, "followers")
    end

    def self.read(user, type)
    # user => MetaTwitter::Auth.config
    # type => string ("followers" or "following")
      Rails.cache.fetch("readmutuals/all/#{MetaTwitter.get_account_id(user)}/#{type}", expires_in: 1.months) do
        target_users = MetaTwitter::ReadFollows.read(user, type)
        self.new.page(user, type, target_users)
      end
    end

    def page(user, type, target_users, mutuals: [], nonmutuals: [], depth: 0, count: 100)
      Rails.cache.fetch("readmutuals/page/#{MetaTwitter.get_account_id(user)}/#{type}/#{depth}", expires_in: 1.months) do

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
      response = MetaTwitter.get_connections(user, target_users)
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
