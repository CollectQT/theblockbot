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

  def self.visible(user)
    blocker_for = BlockList.joins(:blocker_records).where(:blockers => {user_id: user.id}).to_a
    not_hidden = BlockList.where(hidden: false).to_a
    (blocker_for + not_hidden).uniq
  end

end
