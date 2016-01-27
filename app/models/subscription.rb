class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :block_list
  has_many :blocks

  validates :user_id, presence: true
  validates :block_list_id, presence: true
  validates_uniqueness_of :user_id, scope: :block_list_id

  def self.add(user_id, block_list_id)
    SubscribeTo.perform_async(user_id, block_list_id)
    Subscription.create(user_id: user_id, block_list_id: block_list_id)
    user = User.find(user_id)
    block_list = BlockList.find(block_list_id)
    user.update_log("[ADD] Subscribed to block list #{block_list.name}")
  end

  def self.remove(user_id, block_list_id)
    UnsubscribeFrom.perform_async(user_id, block_list_id)
    Subscription.find_by(user_id: user_id, block_list_id: block_list_id).delete
    user = User.find(user_id)
    block_list = BlockList.find(block_list_id)
    user.update_log("[REMOVE] Unsubscribed from block list #{block_list.name}")
  end

end
