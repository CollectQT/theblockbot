$stdout.sync = true

TwitterClient.Stream.user do |object|
  case object
  when Twitter::Tweet
    puts('[Adding to Reports] ' + object.text)
    Report.create(text: object.text)
  when Twitter::DirectMessage
    puts('[Adding to Reports] ' + object.text)
    Report.create(text: object.text)
  when Twitter::Streaming::StallWarning
    warn "Falling behind!"
  end

end
