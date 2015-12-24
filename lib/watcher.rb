# dont buffer and sort stdout
# consider disabling for production
$stdout.sync = true


track = 'lynncyrin #block'

puts 'Starting Watcher for "'+track+'"'

TwitterClient.Stream.filter(track: track) do |object|
  if object.is_a? Twitter::Tweet
    Report.parse(object.text)
  end
end
