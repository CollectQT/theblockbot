class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :block_list
  has_many :blocks

  def self.to(block_list_id)
    Subscription.create(user_id: @current_user.id, block_list_id: block_list_id)
  end

end
