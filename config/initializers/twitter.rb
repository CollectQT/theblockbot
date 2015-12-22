class TwitterClient
    cattr_accessor :REST, :Stream
end

twitterSecrets = {
    consumer_key: ENV['twitter_consumer_key'],
    consumer_secret: ENV['twitter_consumer_secret'],
    access_token: ENV['twitter_access_token'],
    access_token_secret: ENV['twitter_access_token_secret'],
}

TwitterClient.REST = Twitter::REST::Client.new(**twitterSecrets)
TwitterClient.Stream = Twitter::Streaming::Client.new(**twitterSecrets)
