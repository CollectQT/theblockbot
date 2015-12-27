class Auth < ActiveRecord::Base
  belongs_to :user

  # returns a user object instead of an auth object
  def self.parse(_auth)

    user = User.get(_auth.extra.raw_info, _auth.provider)

    if _auth.provider == 'twitter'
      Auth.find_or_create_by(user_id: user.id) do |auth|
        auth.key    = _auth.credentials.token
        auth.secret = _auth.credentials.secret
      end

    elsif website == 'facebook'
      raise 'facebook not yet implemented'

    elsif website == 'tumblr'
      raise 'tumblr not yet implemented'

    end

    return user
  end

end
