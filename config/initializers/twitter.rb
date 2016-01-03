class TwitterClient
  cattr_accessor :REST, :Stream

  def self.user(auth)
    Twitter::REST::Client.new(
      consumer_key: TwitterClient.REST.consumer_key,
      consumer_secret: TwitterClient.REST.consumer_secret,
      access_token: auth.key,
      access_token_secret: auth.secret,
    )
  end

end

twitterSecrets = {
    consumer_key: ENV['twitter_consumer_key'],
    consumer_secret: ENV['twitter_consumer_secret'],
    access_token: ENV['twitter_access_token'],
    access_token_secret: ENV['twitter_access_token_secret'],
}

TwitterClient.REST = Twitter::REST::Client.new(**twitterSecrets)
TwitterClient.Stream = Twitter::Streaming::Client.new(**twitterSecrets)
