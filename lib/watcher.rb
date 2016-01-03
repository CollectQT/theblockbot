# dont buffer and sort stdout
# consider disabling for production
$stdout.sync = true


track = 'lynncyrin #block'

puts 'Starting Watcher for "'+track+'"'

TweetStream::Client.new.track(track) do |status|
  Report.parse(status.text, status.user)
end
