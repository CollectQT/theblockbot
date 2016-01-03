class Block < ActiveRecord::Base
  belongs_to :block_list
  belongs_to :user
  belongs_to :reporter, class_name: "User"
  belongs_to :target, class_name: "User"
  belongs_to :approver, class_name: "User"
  belongs_to :report

  validates_uniqueness_of :target, scope: :user

end
