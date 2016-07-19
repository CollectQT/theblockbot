class BlockList < ActiveRecord::Base
  has_many :reports
  has_many :blocks

  has_many :subscriptions
  has_many :users, through: :subscriptions

  has_many :active_reports, -> { where(approved: true, expired: false) }, class_name: 'Report'
  has_many :targets, through: :active_reports

  has_many :admin_records, class_name: 'Admin', dependent: :destroy
  has_many :admins, through: :admin_records, source: :user, dependent: :destroy

  has_many :blocker_records, class_name: 'Blocker', dependent: :destroy
  has_many :blockers, through: :blocker_records, source: :user, dependent: :destroy

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  def blocker?(user)
    user.in? self.blockers
  end

  def admin?(user)
    user.in? self.admins
  end

  def blocker_autoapprove?(user)
    (self.autoapprove_blocker?) and (self.blocker? user)
  end

  def admin_autoapprove?(user)
    (self.autoapprove_admin?) and (self.admin? user)
  end

  def self.where_blocker(user)
    self.joins(:blocker_records).where(:blockers => {user_id: user.id})
  end

  def self.where_admin(user)
    self.joins(:admin_records).where(:admins => {user_id: user.id})
  end

  def self.make(name, user)
    block_list = self.create(:name => name)
    Admin.create(block_list: block_list, user: user)
    return block_list
  end

  def self.get_expiration(block_list)
    block_list.expires ? DateTime.now + block_list.expires : nil
  rescue NoMethodError
    nil
  end

  def self.find_by_name(name)
    name = MetaTwitter.strip_if_leading_character(name, '#')
    self.where("replace(lower(name), ' ', '') = ?", name.downcase).first
  end

end
