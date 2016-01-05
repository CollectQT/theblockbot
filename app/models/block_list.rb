class BlockList < ActiveRecord::Base
  has_many :reports
  has_many :blocks
  has_many :subscriptions
  has_many :users, through: :subscriptions
  has_many :targets, through: :blocks

  validates :name, presence: true

end
