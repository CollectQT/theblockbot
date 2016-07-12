class Report < ActiveRecord::Base
  belongs_to :block_list
  belongs_to :reporter, class_name: "User"
  belongs_to :target, class_name: "User"
  belongs_to :approver, class_name: "User"
  has_many :blocks

  validates :reporter, presence: true
  validates_presence_of :block_list,
    message: "Must include a valid block list"
  validates_presence_of :text,
    message: 'Report cannot be blank'
  validates_presence_of :target,
    message: "Need to specify who to report with \"+USERNAME\""
  validates_uniqueness_of :text, scope: :reporter_id,
    message: "You have already created this report"

  scope :pending, -> { where(processed: false) }
  scope :active, -> { where(approved: true, expired: false) }
  scope :denied, -> { where(processed: true, approved: false) }

  def self.visible(user)
    if user == nil
      self.none
    else
      self.joins(:block_list => :blockers).where(:blockers => {user_id: user.id})
    end
  end

  def self.parse_regex(text, reporter)
  # text -> string ("+lynncyrin #cats")
  # reports -> User

    reporter = User.get(reporter)

    match_target = text.match('(?<=\+)\@*\w*')
    target = match_target ? User.get_from_twitter_name(match_target[0]) : nil

    match_list = text.match('(?<=\#)\w*')
    block_list = match_list ? BlockList.find_by_name(match_list[0]) : nil

    self.parse_objects(text, block_list, reporter, target)
  end

  def self.parse_text_args(text, reporter, block_list, target)
  # text -> string
  # reporter -> User
  # block_list -> string
  # target -> string

    block_list = BlockList.find_by_name(block_list)
    target = User.get_from_twitter_name(target)

    # self.parse_objects(text, block_list, reporter, target, expires)
  end

  def self.parse_objects(text, block_list, reporter, target)
  # text -> string
  # block_list -> BlockList
  # reporter -> User
  # target -> User
  # expires -> DateTime

    report = Report.create(
      text: text,
      block_list: block_list,
      reporter: reporter,
      target: target,
      expires: block_list.get_expiration,
    )

    reporter.increment(:reports_created)
    target.increment(:times_reported)
    report.check_autoapprove(report.reporter)

    return report
  end

  def check_autoapprove(approver)
    if (self.block_list.blocker_autoapprove? approver) or (self.block_list.admin_autoapprove? approver)
      self.approve(approver)
    end
  end

  def approve(approver)
    if approver.in? self.block_list.blockers
      CreateBlocksFromReport.perform_async(self.id)
      self.update_attributes(approver: approver, approved: true, processed: true)
      self.target.increment(:times_blocked)
      self.reporter.increment(:reports_approved)
    else
      puts 'User(#{approver.id}) Not Authorized to approve Report(#{self.id})'
    end
  end

  def deny(approver)
    if approver.in? self.block_list.blockers
      self.update_attributes(processed: true)
    else
      puts 'User(#{approver.id}) Not Authorized to deny Report(#{self.id})'
    end
  end

end
