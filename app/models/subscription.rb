class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :block_list
  has_many :blocks

  validates :user_id, presence: true
  validates :block_list_id, presence: true
  validates_uniqueness_of :user_id, scope: :block_list_id

  def self.add(user, block_list)
    CreateBlocksFromSubscribe.perform_async(user.id, block_list.id)
    Subscription.create(user_id: user.id, block_list_id: block_list.id)
    user.update_log("[ADD] Subscribed to block list #{block_list.name}")
  end

  def self.remove(user, block_list)
    CreateUnblocksFromUnsubscribe.perform_async(user.id, block_list.id)
    Subscription.find_by(user_id: user.id, block_list_id: block_list.id).delete
    user.update_log("[REMOVE] Unsubscribed from block list #{block_list.name}")
  end

end
