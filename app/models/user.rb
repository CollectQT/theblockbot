class User < ActiveRecord::Base
  has_one :auth
  has_many :subscriptions
  validates :website, presence: true
  validates :account_id, presence: true
  validates_uniqueness_of [:website, :account_id]

  def self.get(_user, website='twitter')

    # https://dev.twitter.com/overview/api/users
    if website == 'twitter'
      User.find_or_create_by(account_id: _user.id.to_s, website: website) do |user|
        user.name                  = _user.name
        user.user_name             = _user.screen_name
        user.account_created       = _user.created_at
        user.default_profile_image = _user.default_profile_image?
        user.description           = _user.description
        user.incoming_follows      = _user.followers_count
        user.outgoing_follows      = _user.friends_count
        user.profile_image_url     = _user.profile_image_url
        user.posts                 = _user.statuses_count
        user.url                   = _user.url.to_s
      end

    # https://developers.facebook.com/docs/graph-api/reference/user
    elsif website == 'facebook'
      raise 'facebook not yet implemented'

    # https://www.tumblr.com/docs/en/api/v2#blog-info
    elsif website == 'tumblr'
      raise 'tumblr not yet implemented'

    end

  rescue ActiveRecord::RecordNotUnique
    tries ||= 0
    (tries += 1) < 3 ? retry : raise
  end

end
