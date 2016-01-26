# dont buffer and sort stdout
# consider disabling for production
$stdout.sync = true


begin
  track = 'lynncyrin #block'
  puts 'Starting Watcher for "'+track+'"'
  TweetStream::Client.new.track(track) do |status|
    Report.parse(status.text, status.user)
  end
# todo: not this
rescue Exception
  puts $!.backtrace
  puts $!.message
  tries ||= 0
  tries += 1
  if tries > 7 then raise end
  sleep_time = 5**tries
  puts "Watcher crashed. Retrying in #{sleep_time} seconds..."
  sleep(sleep_time)
  retry
end
