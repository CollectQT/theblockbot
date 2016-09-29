class Report < ActiveRecord::Base
  belongs_to :block_list
  belongs_to :reporter, class_name: User
  belongs_to :target, class_name: User
  belongs_to :approver, class_name: User
  has_many :blocks

  belongs_to :parent, class_name: self
  has_many :children, class_name: self, foreign_key: :parent_id

  validates :reporter, presence: true
  validates_presence_of :block_list,
    message: "Must include a valid block list"
  validates_presence_of :text,
    message: 'Report cannot be blank'
  validates_presence_of :target,
    message: "Need to specify who to report with \"+USERNAME\""
  validates_uniqueness_of :text, scope: [:block_list, :reporter, :target,],
    message: "You have already created this report"

  scope :pending, -> { where(processed: false, parent_id: 1) }
  scope :active, -> { where(approved: true, expired: false, parent_id: 1) }
  scope :denied, -> { where(processed: true, approved: false, parent_id: 1) }
  scope :is_parent, -> { where(parent_id: 1) }

  def child?
    self.parent_id != 1
  end

  def self.visible(user)
    if user == nil
      self.none
    else
      self.joins(:block_list => :blockers).where(:blockers => {user_id: user.id})
    end
  end

  def self.parse_regex(text:, reporter:)
  # text -> string ("+lynncyrin #cats")
  # reporter -> User

    match_target = text.match('(?<=\+)\@*\w*')
    target = match_target ? User.get_from_twitter_name(match_target[0]) : nil

    match_list = text.match('(?<=\#)\w*')
    block_list = match_list ? BlockList.find_by_name(match_list[0]) : nil

    self.parse_objects(
      block_list: block_list,
      target:     target,
      text:       text,
      reporter:   reporter,
    )

  end

  def self.parse_text_args(block_list:, target:, text:, reporter:)
  # block_list -> string ("cats")
  # target -> string ("lynncyrin")
  # text -> string ("knocked my mouse off the desk")
  # reporter -> User

    self.parse_objects(
      block_list: BlockList.find_by_name(block_list),
      target:     User.get_from_twitter_name(target),
      text:       text,
      reporter:   reporter,
    )
  end

  def self.parse_objects(block_list:, target:, text:, reporter:, parent_id: nil)
  # block_list -> BlockList
  # target -> User
  # text -> string
  # reporter -> User

    expires = BlockList.get_expiration(block_list)
    parent_id = parent_id ? parent_id : self.set_parent(block_list, target)

    report = self.find_or_create_by(
      text: text,
      block_list: block_list,
      reporter: reporter,
      target: target,
    )
    report.update_attributes(
      expires: expires,
      parent_id: parent_id,
    )

    report.reporter.increment(:reports_created)
    report.target.increment(:times_reported)
    report.process_child
    report.autoapprove

    report
  end

  def self.set_parent(block_list, target)
    parent = self.get_parent(block_list, target)
    parent != nil ? parent.id : 1
  end

  def self.get_parent(block_list, target)
    self.is_parent.where(
      :block_list => block_list,
      :target     => target,
    ).first
  end

  def process_child
    if self.child? then self.update_attributes(processed: true) end
  end

  def autoapprove
    if not (self.processed? or self.child?)
      if (self.block_list.blocker_autoapprove? self.reporter) or (self.block_list.admin_autoapprove? self.reporter)
        self.approve(self.reporter)
      end
    end
  rescue NoMethodError
  end

  def approve(approver)
    if (approver.in? self.block_list.blockers) and not (self.processed? or self.child?)
      # temporarily disabled pending a rewrite
      # CreateBlocksFromReport.perform_async(self.id)
      self.update_attributes(approver: approver, approved: true, processed: true)
      self.target.increment(:times_blocked)
      self.reporter.increment(:reports_approved)
    else
      logger.info { "User(#{approver.id}) Not Authorized to approve Report(#{self.id})" }
    end
  end

  def deny(approver)
    if (approver.in? self.block_list.blockers) and (not self.processed?)
      self.update_attributes(processed: true)
    else
      logger.info { "User(#{approver.id}) Not Authorized to deny Report(#{self.id})" }
    end
  end

end
