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

  validates :name, presence: true

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

end
