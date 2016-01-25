class Blocker < ActiveRecord::Base
  belongs_to :user
  belongs_to :block_list

  validates_presence_of :user
  validates_presence_of :block_list

end
