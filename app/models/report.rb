class Report < ActiveRecord::Base
  belongs_to :block_list
  belongs_to :reporter, class_name: "User"
  belongs_to :target, class_name: "User"
  belongs_to :approver, class_name: "User"
  has_many :blocks

  validates :text, presence: true
  validates :block_list_id, presence: true
  validates :reporter_id, presence: true
  validates :target_id, presence: true

  validates_uniqueness_of :text, scope: :reporter_id


  def self.parse(text, reporter)
    puts '[Incoming Report] '+text.squish
    text_included_a_list = false

    reporter = User.get(reporter)
    puts '[Incoming Report] Reporter @'+reporter.user_name
    reporter.increment(:reports_created)

    match = text.match('(?<=\+)\w*')[0]
    puts '[Incoming Report] Target user @'+match
    target = User.get(TwitterClient.REST.user('@'+match))
    target.increment(:times_reported)

    for blocklist in BlockList.all()
      if ('#'+blocklist.name).downcase.delete(' ').in? text.downcase
        puts '[Created Report('+blocklist.name+')] '+text.squish
        Report.create(
          text: text,
          block_list: blocklist,
          reporter: reporter,
          target: target
        )
        text_included_a_list = true
      end
    end

    unless text_included_a_list
      blocklist = BlockList.find(name: 'General')
      puts '[Created Report('+blocklist.name+')] '+text.squish
      Report.create(
        text: text,
        block_list: blocklist,
        reporter: reporter,
        target: target
      )
    end

    # some report level default parsing

  end

end
