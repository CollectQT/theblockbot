def rescue_rate_limit
  yield
rescue Twitter::Error::TooManyRequests => error
  tries ||= 0
  tries += 1
  if tries < 6
    Rails.logger.warn "Hit Twitter rate limit in lib/meta_twitter.rb, current retries: #{tries}/5"
    sleep error.rate_limit.reset_in + tries + 1
    retry
  else
    Rails.logger.error "Exhausted all rate limit retries in lib/meta_twitter.rb"
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

  def self.strip_if_leading_character(string, character)
  # string -> string ('@cats' or '#cats' or 'cats')
  # character -> string ('#' or '@')
    string[0] == character ? string[1..string.length] : string
  end

  def self.get_account_id(user)
  # user => MetaTwitter::Auth.config
    user.access_token.split('-')[0]
  end

  def self.read_user_from_ENV
    MetaTwitter.get_account_id(TwitterClient)
  end

  def self.read_user_from_twitter_id(id)
  # id => int (1111111111111111)
    Rails.cache.fetch("/read_from_id/#{id}", expires_in: 1.hours) do
      rescue_not_found {
      rescue_rate_limit {
        Rails.logger.debug { "GET Twitter.user #{id}" }
        TwitterClient.user(id.to_i).to_h
      }}
    end
  end

  def self.read_user_from_twitter_name(name)
  # name => string ('@cyrin')
    name = MetaTwitter.strip_if_leading_character(name, '@')
    Rails.cache.fetch("/read_from_name/#{name}", expires_in: 1.hours) do
      rescue_not_found {
      rescue_rate_limit {
        Rails.logger.debug { "GET Twitter.user #{name}" }
        TwitterClient.user(name).to_h
      }}
    end
  end

  def self.read_users_from_ids(ids)
  # ids => array(int) ([111111,], max size: 100)
    key = Digest::MD5.hexdigest(ids.to_s)
    Rails.cache.fetch("/read_from_bulk_ids/#{key}", expires_in: 1.days) do
      rescue_not_found {
      rescue_rate_limit {
        Rails.logger.debug { "GET Twitter.users #{key}" }
        users = TwitterClient.users(ids)
      }}
      users = (users).map { |user| user.to_h }
    end
  end

  ############################################

  def self.get_following?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = MetaTwitter.get_account_id(user)
    Rails.cache.fetch("#{user_id}/following?/#{target_id}", expires_in: 1.weeks) do
      rescue_rate_limit {
        Rails.logger.debug { "GET Twitter.friendship? #{user_id} #{target_id}" }
        user.friendship?(user, target_id)
      }
    end
  end

  def self.get_following_ids(user, target, cursor, count)
  # user => MetaTwitter::Auth.config
  # target => str (@name, like @twitter)
  # cursor => int
  # count => int
    user_id = MetaTwitter.get_account_id(user)
    Rails.cache.fetch("#{target}/all_following/#{cursor}/context#{user_id}", expires_in: 1.months) do
      rescue_rate_limit {
        Rails.logger.debug { "GET Twitter.friend_ids #{target} #{cursor} (context #{user_id})" }
        user.friend_ids(target, :cursor => cursor, :count => count).to_h
      }
    end
  end

  def self.get_follower?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = MetaTwitter.get_account_id(user)
    Rails.cache.fetch("#{user_id}/follower?/#{target_id}", expires_in: 1.weeks) do
      rescue_rate_limit {
        Rails.logger.debug { "GET Twitter.friendship? #{target_id} #{user_id}" }
        user.friendship?(target_id, user)
      }
    end
  end

  def self.get_follower_ids(user, target, cursor, count)
  # user => MetaTwitter::Auth.config
  # target => str (@name, like @twitter)
  # cursor => int
  # count => int
    user_id = MetaTwitter.get_account_id(user)
    Rails.cache.fetch("#{target}/all_followers/#{cursor}/context#{user_id}", expires_in: 1.months) do
      rescue_rate_limit {
        Rails.logger.debug { "GET Twitter.follower_ids #{target} #{cursor} (context #{user_id})" }
        user.follower_ids(target, :cursor => cursor, :count => count).to_h
      }
    end
  end

  def self.get_blocked_ids(user, cursor, count)
  # user => MetaTwitter::Auth.config
  # cursor => int
  # count => int
    user_id = MetaTwitter.get_account_id(user)
    Rails.cache.fetch("#{user_id}/blocked_ids/#{cursor}", expires_in: 1.days) do
      rescue_rate_limit {
        Rails.logger.debug { "GET Twitter.blocked_ids #{user_id} #{cursor}" }
        user.blocked_ids(cursor: cursor, count: count).to_h
      }
    end
  end

  def self.get_blocked?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = MetaTwitter.get_account_id(user)
    Rails.cache.fetch("#{user_id}/blocked?/#{target_id}", expires_in: 1.weeks) do
      rescue_rate_limit {
        Rails.logger.debug { "GET Twitter.block? #{user_id} #{target_id}" }
        user.block?(target_id)
      }
    end
  end

  def self.get_connections(user, target_users)
  # user => MetaTwitter::Auth.config
  # target_users => [Twitter.user.id,] length <= 100
    Rails.logger.debug {
      user_id = MetaTwitter.get_account_id(user)
      key = Digest::MD5.hexdigest(target_users.to_s)
      "GET Twitter.friendships #{user_id} #{key}"
    }

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

  # following_self  = MetaTwitter::ReadFollows.from_following( MetaTwitter::Auth.config( User.find_by(user_name: 'lynncyrin') ) )
  # followers_self  = MetaTwitter::ReadFollows.from_followers( MetaTwitter::Auth.config( User.find_by(user_name: 'lynncyrin') ) )
  # following_other = MetaTwitter::ReadFollows.from_following( MetaTwitter::Auth.config( User.find_by(user_name: 'lynncyrin') ), target: '@cyrin_test' )

  class ReadFollows

    def self.from_followers(user, target: nil)
    # user => MetaTwitter::Auth.config
      self.read(user, "followers", target: target)
    end

    def self.from_following(user, target: nil)
    # user => MetaTwitter::Auth.config
      self.read(user, "following", target: target)
    end

    def self.read(user, type, target: nil)
    # user => MetaTwitter::Auth.config
    # type => string ("followers" or "following")
      user_account_id = MetaTwitter.get_account_id(user)
      target          = target.nil? ? user_account_id : target

      Rails.cache.fetch("fof/all/#{user_account_id}/#{type}", expires_in: 1.months) do
        self.new.page(user, type, target)
      end
    end

    def page(user, type, target, fof: [], cursor: -1)
      Rails.cache.fetch("fof/page/#{MetaTwitter.get_account_id(user)}/#{type}/#{cursor}", expires_in: 1.months) do
        if cursor != 0
          fof, cursor = process_page(user, type, target, fof, cursor)
          page(user, type, target, fof: fof, cursor: cursor)
        else
          fof
        end
      end
    end

    private def process_page(user, type, target, fof, cursor, count: 5000)
      if type == 'followers'
        response = MetaTwitter.get_follower_ids(user, target, cursor, count)
      elsif type == 'following'
        response = MetaTwitter.get_following_ids(user, target, cursor, count)
      end
      fof = fof + response[:ids]
      cursor = response[:next_cursor]
      return fof, cursor
    end

  end

  ############################################

  # mutuals = MetaTwitter::ReadMutuals.from_following( MetaTwitter::Auth.config( User.find_by(user_name: 'lynncyrin') ) )
  # mutuals = MetaTwitter::ReadMutuals.from_followers( MetaTwitter::Auth.config( User.find_by(user_name: 'lynncyrin') ) )

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

  ############################################

  # ids = MetaTwitter::BlockIds.read( MetaTwitter::Auth.config( User.find_by(user_name:'lynncyrin') ) )

  class BlockIds

    def self.read(user)
    # user => MetaTwitter::Auth.config
      self.new.page(user)
    end

    def page(user, ids: [], cursor: -1)
      Rails.cache.fetch("blockids/page/#{MetaTwitter.get_account_id(user)}/#{cursor}", expires_in: 1.days) do
        if cursor != 0
          ids, cursor = process_page(user, ids, cursor)
          page(user, ids: ids, cursor: cursor)
        else
          ids
        end
      end
    end

    private def process_page(user, ids, cursor, count: 5000)
      response = MetaTwitter.get_blocked_ids(user, cursor, count)
      ids = ids + response[:ids]
      cursor = response[:next_cursor]
      return ids, cursor
    end

  end

end
