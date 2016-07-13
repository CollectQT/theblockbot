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

  delegate :token, to: :auth
  delegate :secret, to: :auth

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

  def self.get_from_twitter_id(id)
  # id => int (1111111111111111)
    self.update_or_create( MetaTwitter.read_user_from_twitter_id(id) )
  end

  def self.get_from_twitter_name(name)
  # name => string ('@cyrin')
    self.update_or_create( MetaTwitter.read_user_from_twitter_name(name) )
  end

  def self.get_from_authed_user
    self.update_or_create( MetaTwitter.read_user_from_auth )
  end

  def self.update_or_create(user)
  # user => dictionary (MetaTwitter.read_user_from_twitter_*)

    # Update Twitter user info
    # https://dev.twitter.com/overview/api/users
    user_model = User.find_or_create_by(account_id: user[:id].to_s)
    user_model.update_attributes(
      name:                   user[:name],
      user_name:              user[:screen_name],
      account_created:        user[:created_at],
      default_profile_image:  user[:default_profile_image?],
      description:            user[:description],
      incoming_follows:       user[:followers_count],
      outgoing_follows:       user[:friends_count],
      profile_image_url:      user[:profile_image_url],
      posts:                  user[:statuses_count],
      url:                    user[:url].to_s,
    )

    return user_model

  # deals with a user being created twice, simultaneously
  rescue ActiveRecord::RecordNotUnique
    tries ||= 0
    (tries += 1) < 3 ? retry : raise
  end

  # randomizes User.id
  private
  def randomize_id
    begin
      self.id = SecureRandom.random_number(10_000_000)
    end while User.where(id: self.id).exists?
  end

end
