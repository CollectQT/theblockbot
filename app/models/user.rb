class User < ActiveRecord::Base
  before_create :randomize_id

  has_one :auth, :dependent => :destroy
  has_many :subscriptions
  has_many :block_lists, through: :subscriptions
  has_many :reports_by, class_name: "Report", foreign_key: "reporter_id"
  has_many :reports_against, class_name: "Report", foreign_key: "target_id"
  has_many :blocker
  has_many :blocker_for, through: :blocker, source: :block_list
  has_many :admin
  has_many :admin_for, through: :admin, source: :block_list
  has_many :blocked_users, through: :block_lists, source: :targets

  validates :website, presence: true
  validates :account_id, presence: true
  validates_uniqueness_of :account_id, scope: :website

  def is_blocker
    self.blocker_for.length > 0
  end

  def is_admin
    self.admin_for.length > 0
  end

  def update_log(entry)
    self.log << entry
    self.save
    puts "(@#{self.user_name}) #{entry}"
  end

  def self.get(_user, website='twitter')

    # get user from string (username) / integer (id) + website
    # example: User.get('nasa', 'twitter')
    if _user.is_a? String or _user.is_a? Integer
      if website == 'twitter'
        _user = TwitterClient.REST.user(_user)

      elsif website == 'facebook'
        raise 'facebook not yet implemented'

      elsif website == 'tumblr'
        raise 'tumblr not yet implemented'

      else
        raise 'invalid website???'
      end
    end

    # sometimes you're tired coding and dont know that you already have a User
    if _user.is_a? User
      user = _user

    # Update Twitter user info
    # https://dev.twitter.com/overview/api/users
    elsif _user.is_a? Twitter::User
      user = User.find_or_create_by(account_id: _user.id.to_s, website: website)
      user.update_attributes(
        name:                   _user.name,
        user_name:              _user.screen_name,
        account_created:        _user.created_at,
        default_profile_image:  _user.default_profile_image?,
        description:            _user.description,
        incoming_follows:       _user.followers_count,
        outgoing_follows:       _user.friends_count,
        profile_image_url:      _user.profile_image_url,
        posts:                  _user.statuses_count,
        url:                    _user.url.to_s
      )
    end

    return user

  # deals with a user being created twice, simultaneously
  rescue ActiveRecord::RecordNotUnique
    tries ||= 0
    (tries += 1) < 3 ? retry : raise
  end

  # randomizes User.id
  private
  def randomize_id
    begin
      self.id = SecureRandom.random_number(1_000_000)
    end while User.where(id: self.id).exists?
  end

end
