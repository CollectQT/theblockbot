def rescue_not_found
  yield
rescue Twitter::Error::NotFound
  nil
end


#############################################


module MetaTwitter
# access with MetaTwitter.function_name

  def self.read_user_from_twitter_id(id)
  # id => int (1111111111111111)
    log_entry = "GET Twitter.user #{id}"
    Rails.cache.fetch("/read_from_id/#{id}", expires_in: 1.hours) do
      rescue_not_found {
        Rails.logger.debug { log_entry }
        TwitterClient.user(id.to_i).to_h
      }
    end
  end

  def self.read_user_from_twitter_name(name)
  # name => string ('@cyrin')
    name = Utils.strip_if_leading_character(name, '@')
    Rails.cache.fetch("/read_from_name/#{name}", expires_in: 1.hours) do
      rescue_not_found {
        Rails.logger.debug { "GET Twitter.user #{name}" }
        TwitterClient.user(name).to_h
      }
    end
  end

  def self.read_users_from_ids(ids)
  # ids => array(int) ([111111,], max size: 100)
    key = Digest::MD5.hexdigest(ids.to_s)
    Rails.cache.fetch("/read_from_bulk_ids/#{key}", expires_in: 1.days) do
      rescue_not_found {
        Rails.logger.debug { "GET Twitter.users #{key}" }
        users = TwitterClient.users(ids)
      }
      users = (users).map { |user| user.to_h }
    end
  end

  ############################################

  def self.get_following?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = Utils.id_from_twitter_auth(user)
    Rails.cache.fetch("#{user_id}/following?/#{target_id}", expires_in: 1.weeks) do
      Rails.logger.debug { "GET Twitter.friendship? #{user_id} #{target_id}" }
      user.friendship?(user, target_id)
    end
  end

  def self.get_following_ids(user, target, cursor)
  # user => MetaTwitter::Auth.config
  # target => str / int (@name / 1234, twitter identifier)
  # cursor => int
    user.friend_ids(target, :cursor => cursor).to_h
  end

  def self.get_followers_ids(user, target, cursor)
  # user => MetaTwitter::Auth.config
  # target => str / int (@name / 1234, twitter identifier)
  # cursor => int
    user.follower_ids(target, :cursor => cursor).to_h
  end

  def self.get_follower?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = Utils.id_from_twitter_auth(user)
    Rails.cache.fetch("#{user_id}/follower?/#{target_id}", expires_in: 1.weeks) do
      Rails.logger.debug { "GET Twitter.friendship? #{target_id} #{user_id}" }
      user.friendship?(target_id, user)
    end
  end

  def self.get_blocked_ids(user, cursor)
  # user => MetaTwitter::Auth.config
  # cursor => int
    user_id = Utils.id_from_twitter_auth(user)
    Rails.cache.fetch("#{user_id}/blocked_ids/#{cursor}", expires_in: 1.weeks) do
      Rails.logger.debug { "GET Twitter.blocked_ids #{user_id} #{cursor}" }
      user.blocked_ids(cursor: cursor).to_h
    end
  end

  def self.get_blocked?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = Utils.id_from_twitter_auth(user)
    Rails.cache.fetch("#{user_id}/blocked?/#{target_id}", expires_in: 1.weeks) do
      Rails.logger.debug { "GET Twitter.block? #{user_id} #{target_id}" }
      user.block?(target_id)
    end
  end

  ############################################

  def self.remove_follow_from_list(user, user_id_list, type)
  # user => MetaTwitter::Auth.config
  # user_id_list => [123, 456, ...]
  # type => "following" | "followed_by"
    user_id_list - MetaTwitter::ReadFollows.read(user, type)
  end

  def self.remove_blocked_from_list(user, user_id_list)
  # user => MetaTwitter::Auth.config
  # user_id_list => [123, 456, ...]
    user_id_list - MetaTwitter::BlockIds.read(user)
  end

  def self.get_mutuals(user)
  # user => MetaTwitter::Auth.config
    followers = MetaTwitter::ReadFollows.from_followers(user)
    following = MetaTwitter::ReadFollows.from_following(user)
    followers - following
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
      user_account_id = Utils.id_from_twitter_auth(user)
      target          = target.nil? ? user_account_id : target
      status          = "fof/#{type}/source:#{user_account_id}/target:#{target}"

      Rails.logger.error { status }
      Rails.cache.fetch(status, expires_in: 1.months) do
        self.new.page(user, type, target)
      end
    end

    def page(user, type, target, fof: [], cursor: -1)
      id = Utils.id_from_twitter_auth(user)
      Rails.cache.fetch("fof/page/#{id}/#{type}/#{cursor}", expires_in: 1.months) do
        if cursor != 0
          fof, cursor = process_page(user, type, target, fof, cursor)
          page(user, type, target, fof: fof, cursor: cursor)
        else
          fof
        end
      end
    end

    private def process_page(user, type, target, fof, cursor)
      if type == 'followers'
        response = MetaTwitter.get_followers_ids(user, target, cursor)
      elsif type == 'following'
        response = MetaTwitter.get_following_ids(user, target, cursor)
      end
      fof = fof + response[:ids]
      cursor = response[:next_cursor]
      return fof, cursor
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
      id = Utils.id_from_twitter_auth(user)
      Rails.cache.fetch("blockids/page/#{id}/#{cursor}", expires_in: 1.days) do
        if cursor != 0
          ids, cursor = process_page(user, ids, cursor)
          page(user, ids: ids, cursor: cursor)
        else
          ids
        end
      end
    end

    private def process_page(user, ids, cursor)
      response = MetaTwitter.get_blocked_ids(user, cursor)
      ids = ids + response[:ids]
      cursor = response[:next_cursor]
      return ids, cursor
    end

  end

end
