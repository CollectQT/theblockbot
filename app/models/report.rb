class Report < ActiveRecord::Base
  belongs_to :block_list
  belongs_to :reporter, class_name: "User"
  belongs_to :target, class_name: "User"
  belongs_to :approver, class_name: "User"
  has_many :blocks

  validates :reporter, presence: true
  validates_presence_of :block_list,
    message: "Must include a block list"
  validates_presence_of :text,
    message: 'Report cannot be blank'
  validates_presence_of :target,
    message: "Need to specify who to report with \"+USERNAME\""
  validates_uniqueness_of :text, scope: :reporter_id,
    message: "You have already created this report"


  def self.visible(user)
    if user == nil
      self.none
    else
      self.joins(:block_list => :blockers).where(:blockers => {user_id: user.id})
    end
  end


  def self.parse(text, reporter)
    puts '[Incoming Report] '+text.squish
    text_included_a_list = false

    reporter = User.get(reporter)

    #todo: make this shorter
    match = text.match('(?<=\+)\w*')
    if match
      target = User.get(TwitterClient.REST.user(match[0]))
    else
      target = nil
    end

    for block_list in BlockList.all()
      if ('#'+block_list.name).downcase.delete(' ').in? text.downcase

        puts "[Created Report(#{block_list.name})] #{text.squish}"

        if block_list.expires
          expires = DateTime.now + block_list.expires
        else
          expires = nil
        end

        report = Report.create(
          text: text,
          block_list: block_list,
          reporter: reporter,
          target: target,
          expires: expires,
        )

        text_included_a_list = true
      end
    end

    unless text_included_a_list
      puts "[!Error! (no list)] #{text.squish}"
      report = Report.create(
        text: text,
        reporter: reporter,
        target: target,
        expires: expires,
      )
    end

    unless target
      puts "[!Error! (no target)] #{text.squish}"
    end

    if target then target.increment(:times_reported) end
    if reporter then reporter.increment(:reports_created) end

    return report

  end


  def approve(approver)
    unless approver.in? self.block_list.blockers
      puts 'User(#{approver_id}) Not Authorized to approve Report(#{report_id})'
      return
    end
    CreateBlocks.perform_async(self.id)
    self.update_attributes(approver: approver, approved: true, processed: true)
    self.target.increment(:times_blocked)
    self.reporter.increment(:reports_approved)
  end


end
