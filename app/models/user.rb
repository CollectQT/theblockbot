class User < ActiveRecord::Base
  has_one :auth
  validates :website, presence: true
  validates :account_id, presence: true
  validates_uniqueness_of [:website, :account_id]

  def self.get(_user, website='twitter')
    if website == 'twitter'
      # https://dev.twitter.com/overview/api/users
      User.find_or_create_by(account_id: _user.id.to_s, website: website) do |user|
        user.display_name          = _user.name
        user.account_created       = _user.created_at
        user.default_profile_image = _user.default_profile_image?
        user.description           = _user.description
        user.incoming_follows      = _user.followers_count
        user.outgoing_follows      = _user.friends_count
        user.profile_image_url     = _user.profile_image_url
        user.user_name             = _user.screen_name
        user.posts                 = _user.statuses_count
        user.url                   = _user.url.to_s
      end
    elsif website == 'facebook'
      # https://developers.facebook.com/docs/graph-api/reference/user
      puts 'facebook not yet implemented'
    elsif website == 'tumblr'
      # https://www.tumblr.com/docs/en/api/v2#blog-info
      puts 'tumblr not yet implemented'
    end
  rescue ActiveRecord::RecordNotUnique
    tries ||= 0
    (tries += 1) < 3 ? retry : raise
  end

end
