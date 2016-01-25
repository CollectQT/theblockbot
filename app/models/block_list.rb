class BlockList < ActiveRecord::Base
  has_many :reports
  has_many :blocks
  has_many :subscriptions
  has_many :users, through: :subscriptions
  has_many :targets, through: :blocks

  has_many :admin_records, class_name: 'Admin', dependent: :destroy
  has_many :admins, through: :admin_records, source: :user, dependent: :destroy

  has_many :blocker_records, class_name: 'Blocker', dependent: :destroy
  has_many :blockers, through: :blocker_records, source: :user, dependent: :destroy

  validates :name, presence: true

  def self.default_scope
    where(hidden: false)
  end

end
