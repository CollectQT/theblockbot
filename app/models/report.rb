class Report < ActiveRecord::Base
  belongs_to :block_list

  def self.parse(text)
    puts '[Incoming Report] '+text.squish

    text_included_a_list = false

    for blocklist in BlockList.all()
      if ('#'+blocklist.name).downcase.in? text.downcase
        puts '[Created Report('+blocklist.name+')] '+text.squish
        Report.create(text: text, block_list_id: blocklist.id)
        text_included_a_list = true
      end
    end

    # unless text_included_a_list
    #   blocklist = BlockList.find(name: 'General')
    #   puts '[Created Report('+blocklist.name+')] '+text.squish
    #   Report.create(text: text, block_list_id: blocklist.id)
    # end
  end

end
