class Report < ActiveRecord::Base
  belongs_to :block_list
  belongs_to :reporter, class_name: "User"
  belongs_to :target, class_name: "User"
  belongs_to :approver, class_name: "User"
  has_many :blocks

  validates :block_list, presence: true
  validates :reporter, presence: true
  validates_presence_of :text, message: 'Report cannot be blank'
  validates_presence_of :target,
    message: "Need to specify who to report with \"+USERNAME\""

  validates_uniqueness_of :text, scope: :reporter_id,
    message: "You have already created this report"


  def self.parse(text, reporter)
    puts '[Incoming Report] '+text.squish
    text_included_a_list = false

    reporter = User.get(reporter)

    #todo: make this shorter
    match = text.match('(?<=\+)\w*')
    if match
      target = User.get(TwitterClient.REST.user('@'+match[0]))
    else
      target = nil
    end

    for blocklist in BlockList.all()
      if ('#'+blocklist.name).downcase.delete(' ').in? text.downcase
        puts "[Created Report(#{blocklist.name})] #{text.squish}"
        report = Report.create(
          text: text,
          block_list: blocklist,
          reporter: reporter,
          target: target
        )
        text_included_a_list = true
      end
    end

    unless text_included_a_list
      puts "[!Error! (no list)] #{text.squish}"
    end
    unless target
      puts "[!Error! (no target)] #{text.squish}"
    end

    if target then target.increment(:times_reported) end
    if reporter then reporter.increment(:reports_created) end

    return report

  end

end
