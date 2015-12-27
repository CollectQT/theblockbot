class BlockList < ActiveRecord::Base
  has_many :reports
  has_many :blocks
  has_many :subscriptions
  has_many :users, through: :subscriptions
end
