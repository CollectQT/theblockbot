class Auth < ActiveRecord::Base
  belongs_to :user

  validates :key, presence: true
  validates :secret, presence: true

  # returns a user object instead of an auth object
  def self.parse(_auth)

    user = User.get(_auth.extra.raw_info.id, _auth.provider)

    if _auth.provider == 'twitter'
      auth = Auth.find_or_create_by(user_id: user.id)
      auth.update_attributes(
        key:    _auth.credentials.token,
        secret: _auth.credentials.secret,
      )

    elsif website == 'facebook'
      raise 'facebook not yet implemented'

    elsif website == 'tumblr'
      raise 'tumblr not yet implemented'

    end

    return user
  end

end
