# dont buffer and sort stdout
# consider disabling for production
$stdout.sync = true


track = 'lynncyrin #block'

puts 'Starting Watcher for "'+track+'"'

def report(text)
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

TwitterClient.Stream.filter(track: track) do |object|
  if object.is_a? Twitter::Tweet
    report object.text
  end
end
