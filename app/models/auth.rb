class Auth < ActiveRecord::Base
  belongs_to :user

  attr_encrypted :token, :key => Rails.application.secrets.secret_key_base
  attr_encrypted :secret, :key => Rails.application.secrets.secret_key_base

  validates :token, presence: true
  validates :secret, presence: true

  # returns a user object instead of an auth object
  def self.parse(_auth)

    user = User.get_from_twitter_id(_auth.extra.raw_info.id.to_i)

    Auth.find_or_create_by(user: user).update_attributes(
      token:    _auth.credentials.token,
      secret:   _auth.credentials.secret,
    )

    return user

  end

  def self.get_from_ENV

    user = User.update_or_create( {id: Utils.read_id_from_ENV} )

    Auth.find_or_create_by(user: user).update_attributes(
      token: TwitterClient.access_token,
      secret: TwitterClient.access_token_secret,
    )

    return user

  end

end
