class User < ActiveRecord::Base
  has_one :auth, :dependent => :destroy
  has_many :subscriptions
  has_many :block_lists, through: :subscriptions
  has_many :reports_by, class_name: "Report", foreign_key: "reporter_id"
  has_many :reports_against, class_name: "Report", foreign_key: "target_id"

  validates :website, presence: true
  validates :account_id, presence: true
  validates_uniqueness_of :account_id, scope: :website

  def self.get(_user, website='twitter')
    # takes in a user object from an API library (ex: the Twitter gem)
    # returns a local User instance

    # sometimes we already have a user object, and aren't aware of it
    if _user.is_a? User
      return _user

    # https://dev.twitter.com/overview/api/users
    elsif website == 'twitter'
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
      return user

    # https://developers.facebook.com/docs/graph-api/reference/user
    elsif website == 'facebook'
      raise 'facebook not yet implemented'

    # https://www.tumblr.com/docs/en/api/v2#blog-info
    elsif website == 'tumblr'
      raise 'tumblr not yet implemented'

    else
      raise 'invalid website???'

    end

  rescue ActiveRecord::RecordNotUnique
    tries ||= 0
    (tries += 1) < 3 ? retry : raise
  end

end
