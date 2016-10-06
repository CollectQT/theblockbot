def rescue_not_found
  yield
rescue Twitter::Error::NotFound
  nil
end


############################################################


module MetaTwitter
# access with MetaTwitter.function_name

############################################################
# user data
############################################################

  def self.read_user_from_twitter_id(id)
  # id => int (1111111111111111)
    status = "/read_from_id/#{id}"

    Rails.cache.fetch(status, expires_in: 1.hours) do
      Rails.logger.info { status }
      rescue_not_found {
        TwitterClient.user(id.to_i).to_h
      }
    end
  end

  def self.read_user_from_twitter_name(name)
  # name => string ('@cyrin')
    name = Utils.strip_if_leading_character(name, '@')
    status = "/read_from_name/#{name}"

    Rails.cache.fetch(status, expires_in: 1.hours) do
      Rails.logger.info { status }
      rescue_not_found {
        TwitterClient.user(name).to_h
      }
    end
  end

  def self.read_users_from_ids(ids)
  # ids => array(int) ([111111,], max size: 100)
    key = Digest::MD5.hexdigest(ids.to_s)
    status = "/read_from_bulk_ids/#{key}"

    Rails.cache.fetch(status, expires_in: 1.days) do
      Rails.logger.info { status }
      rescue_not_found {
        users = TwitterClient.users(ids)
      }
      users = (users).map { |user| user.to_h }
    end
  end

############################################################
# boolean checks
############################################################

  def self.following?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = Utils.id_from_twitter_auth(user)
    status = "#{user_id}/following?/#{target_id}"

    Rails.cache.fetch(status, expires_in: 1.weeks) do
      Rails.logger.info { status }
      user.friendship?(user, target_id)
    end
  end

  def self.follower?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = Utils.id_from_twitter_auth(user)
    status = "#{user_id}/follower?/#{target_id}"

    Rails.cache.fetch(status, expires_in: 1.weeks) do
      Rails.logger.info { status }
      user.friendship?(target_id, user)
    end
  end

  def self.blocked?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = Utils.id_from_twitter_auth(user)
    status = "#{user_id}/blocked?/#{target_id}"

    Rails.cache.fetch(status, expires_in: 1.weeks) do
      Rails.logger.info { status }
      user.block?(target_id)
    end
  end

############################################################
# user lists
############################################################

  def self.get_followers(user, target: nil)
  # user => MetaTwitter::Auth.config( User.find_by(user_name: 'lynncyrin') )
    MetaTwitter::ReadFollows.read(user, "followers", target: target)
  end

  def self.get_following(user, target: nil)
  # user => MetaTwitter::Auth.config( User.find_by(user_name: 'lynncyrin') )
    MetaTwitter::ReadFollows.read(user, "following", target: target)
  end

  def self.get_mutuals(user)
  # user => MetaTwitter::Auth.config( User.find_by(user_name: 'lynncyrin') )
    MetaTwitter.get_followers(user) - MetaTwitter.get_following(user)
  end

  def self.get_blocked(user)
  # user => MetaTwitter::Auth.config( User.find_by(user_name: 'lynncyrin') )
    MetaTwitter::BlockIds.read(user)
  end


############################################################


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


############################################################


  class ReadFollows

    def self.read(user, type, target: nil)
    # user => MetaTwitter::Auth.config
    # type => string ("followers" or "following")
      user_account_id = Utils.id_from_twitter_auth(user)
      target          = target.nil? ? user_account_id : target
      status          = "fof/#{type}/source:#{user_account_id}/target:#{target}"

      Rails.cache.fetch(status, expires_in: 1.months) do
        Rails.logger.info { status }
        self.new.page(user, type, target)
      end
    end

    def page(user, type, target, fof: [], cursor: -1)
      user_account_id = Utils.id_from_twitter_auth(user)
      status = "fof/#{type}/source:#{user_account_id}/target:#{target}/page:#{cursor}"

      Rails.cache.fetch(status, expires_in: 1.months) do
        Rails.logger.info { status }
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
        response = user.follower_ids(target, :cursor => cursor).to_h
      elsif type == 'following'
        response = user.friend_ids(target, :cursor => cursor).to_h
      end
      fof = fof + response[:ids]
      cursor = response[:next_cursor]
      return fof, cursor
    end

  end


############################################################


  class BlockIds

    def self.read(user)
      user_account_id = Utils.id_from_twitter_auth(user)
      status          = "blockids/source:#{user_account_id}/"

      Rails.cache.fetch(status, expires_in: 1.months) do
        Rails.logger.info { status }
        self.new.page(user)
      end
    end

    def page(user, ids: [], cursor: -1)
      user_account_id = Utils.id_from_twitter_auth(user)
      status = "blockids/source:#{user_account_id}/page:#{cursor}"

      Rails.cache.fetch(status, expires_in: 1.months) do
        Rails.logger.info { status }
        if cursor != 0
          ids, cursor = process_page(user, ids, cursor)
          page(user, ids: ids, cursor: cursor)
        else
          ids
        end
      end
    end

    private def process_page(user, ids, cursor)
      response = user.blocked_ids(cursor: cursor).to_h
      ids = ids + response[:ids]
      cursor = response[:next_cursor]
      return ids, cursor
    end

  end

end
