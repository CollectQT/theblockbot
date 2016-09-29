class BlockList < ActiveRecord::Base
  has_many :reports
  has_many :blocks

  has_many :subscriptions
  has_many :users, through: :subscriptions

  has_many :active_reports, -> { where(approved: true, expired: false) }, class_name: Report
  has_many :targets, through: :active_reports

  has_many :admin_records, class_name: Admin, dependent: :destroy
  has_many :admins, through: :admin_records, source: :user, dependent: :destroy

  has_many :blocker_records, class_name: Blocker, dependent: :destroy
  has_many :blockers, through: :blocker_records, source: :user, dependent: :destroy

  validates :name, presence: true, uniqueness: {case_sensitive: false}


  def blocker?(user)
    user.in? self.blockers
  end


  def admin?(user)
    user.in? self.admins
  end


  def self.where_blocker(user)
    self.joins(:blocker_records).where(:blockers => {user_id: user.id})
  end


  def self.where_admin(user)
    self.joins(:admin_records).where(:admins => {user_id: user.id})
  end


  def blocker_autoapprove?(user)
    (self.autoapprove_blocker?) and (self.blocker? user)
  end


  def admin_autoapprove?(user)
    (self.autoapprove_admin?) and (self.admin? user)
  end


  def add_admin(user, authorized_by: nil, list_recently_created: nil)
    if (self.admin? authorized_by) or (list_recently_created)
      Admin.find_or_create_by(user: user, block_list: self)
      user.update_log("Became admin of block list #{self.name}")
    end
  end


  def add_blocker(user, authorized_by)
    if self.admin? authorized_by
      Blocker.find_or_create_by(user: user, block_list: self)
      user.update_log("Became blocker of block list #{self.name}")
    end
  end


  def remove_admin(user, authorized_by)
    if (user.id == authorized_by.id) or (self.admin? authorized_by)
      Admin.find_by(user: user, block_list: self).delete
      user.update_log("Removed as admin for block list #{self.name}")
    end
  end


  def remove_blocker(user, authorized_by)
    if (user.id == authorized_by.id) or (self.admin? authorized_by)
      Blocker.find_by(user: user, block_list: self).delete
      user.update_log("Removed as blocker for block list #{self.name}")
    end
  end


  def subscribe(user)
    CreateBlocksFromSubscribe.perform_async(user.id, self.id)
    Subscription.find_or_create_by(user: user, block_list: self)
    user.update_log("Subscribed to block list #{self.name}")
  end


  def unsubscribe(user)
    CreateUnblocksFromUnsubscribe.perform_async(user.id, self.id)
    Subscription.find_by(user: user, block_list: self).delete
    user.update_log("Un-subscribed from block list #{self.name}")
  end


  def self.make(name:, user:, description: nil, expires: 365, private_list: false)
    block_list = self.find_or_create_by(
      name: name
    )
    block_list.update_attributes(
      expires: expires,
      private_list: private_list,
      description: description unless description.nil?,
    )
    user.update_log("Created block_list #{block_list.name}")

    block_list.add_admin(user, list_recently_created: true)
    block_list.subscribe(user)

    block_list
  end


  def self.get_expiration(block_list)
    block_list.expires ? DateTime.now + block_list.expires : nil
  rescue NoMethodError
    nil
  end


  def self.find_by_name(name)
    name = Utils.strip_if_leading_character(name, '#')
    self.where("replace(lower(name), ' ', '') = ?", name.downcase).first
  end


end
