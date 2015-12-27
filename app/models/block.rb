class Block < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :block_list
end
