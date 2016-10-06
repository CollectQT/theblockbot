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

############################################################
# boolean checks
############################################################

  def self.following?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = Utils.id_from_twitter_auth(user)
    Rails.cache.fetch("#{user_id}/following?/#{target_id}", expires_in: 1.weeks) do
      Rails.logger.debug { "GET Twitter.friendship? #{user_id} #{target_id}" }
      user.friendship?(user, target_id)
    end
  end

  def self.follower?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = Utils.id_from_twitter_auth(user)
    Rails.cache.fetch("#{user_id}/follower?/#{target_id}", expires_in: 1.weeks) do
      Rails.logger.debug { "GET Twitter.friendship? #{target_id} #{user_id}" }
      user.friendship?(target_id, user)
    end
  end

  def self.blocked?(user, target_id)
  # user => MetaTwitter::Auth.config
  # target_id => int
    user_id = Utils.id_from_twitter_auth(user)
    Rails.cache.fetch("#{user_id}/blocked?/#{target_id}", expires_in: 1.weeks) do
      Rails.logger.debug { "GET Twitter.block? #{user_id} #{target_id}" }
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

      Rails.logger.error { status }
      Rails.cache.fetch(status, expires_in: 1.months) do
        self.new.page(user, type, target)
      end
    end

    def page(user, ids: [], cursor: -1)
      id = Utils.id_from_twitter_auth(user)
      Rails.cache.fetch("blockids/page/#{id}/#{cursor}", expires_in: 1.months) do
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
