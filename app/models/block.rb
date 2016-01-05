class Block < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, class_name: "User"
  belongs_to :report

  validates_uniqueness_of :target, scope: :user

  delegate :text, to: :report
  delegate :approver, to: :report
  delegate :reporter, to: :report
  delegate :block_list, to: :report

end
