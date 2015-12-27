class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :block_list
  has_many :blocks

  validates :user_id, presence: true
  validates :block_list_id, presence: true
  validates_uniqueness_of :user_id, scope: :block_list_id
end
