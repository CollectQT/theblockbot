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

  scope :id_only, -> { where(:user_name => nil) }

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

  def self.get_from_twitter_ids(ids)
  # ids => array[int] ([111111,])
    users = MetaTwitter.read_users_from_ids(ids)
    users = (users).map { |user| self.update_or_create(user) }
  end

  def self.get_from_ENV
    Auth.get_from_ENV
  end

  def self.update_or_create(user)
  # user => {id: 11111111,}

    # Update Twitter user info
    # https://dev.twitter.com/overview/api/users
    model = User.find_or_create_by(account_id: user[:id].to_s, website: 'twitter')
    model.update_attributes(
      name:                   user.fetch(:name, nil),
      user_name:              user.fetch(:screen_name, nil),
      account_created:        user.fetch(:created_at, nil),
      default_profile_image:  user.fetch(:default_profile_image?, nil),
      description:            user.fetch(:description, nil),
      incoming_follows:       user.fetch(:followers_count, nil),
      outgoing_follows:       user.fetch(:friends_count, nil),
      profile_image_url:      user.fetch(:profile_image_url, nil),
      posts:                  user.fetch(:statuses_count, nil),
      url:                    user.fetch(:url, nil).to_s,
    )

    return model

  # deals with a user being created twice, simultaneously
  rescue ActiveRecord::RecordNotUnique
    tries ||= 0
    (tries += 1) < 3 ? retry : raise
  end

  def self.ids_to_models(ids)
    (ids).map { |id| self.update_or_create({:id => id}) }
  end

  def get_followers
    User.ids_to_models(
      MetaTwitter::ReadFollows.from_followers(
        MetaTwitter::Auth.config(self)
      )
    )
  end

  def get_following
    User.ids_to_models(
      MetaTwitter::ReadFollows.from_following(
        MetaTwitter::Auth.config(self)
      )
    )
  end

  # randomizes User.id
  private
  def randomize_id
    begin
      self.id = SecureRandom.random_number(10_000_000)
    end while User.where(id: self.id).exists?
  end

end
