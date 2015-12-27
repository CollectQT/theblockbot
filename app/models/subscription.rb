class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :block_list
  has_many :blocks

  validates :user_id, presence: true
  validates :block_list_id, presence: true
  validates_uniqueness_of [:user_id, :block_list_id]

  def self.to(block_list_id, user_id=@current_user.id)
    Subscription.create(user_id: user_id, block_list_id: block_list_id)
  end

end
