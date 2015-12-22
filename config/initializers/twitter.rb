# looks the following in secrets.yml
#
# development:
#   twitter_consumer_key: XXXXXXXXXXXXXXXXXXXXXXXXXXX
#   twitter_consumer_secret: XXXXXXXXXXXXXXXXXXXXXXXX
#   twitter_access_token: XXXXXXXXXXXXXXXXXXXXXXXXXXX
#   twitter_access_token_secret: XXXXXXXXXXXXXXXXXXXX

class TwitterClient
    cattr_accessor :REST, :Stream
end

twitterSecrets = {
    consumer_key: Rails.application.secrets.twitter_consumer_key,
    consumer_secret: Rails.application.secrets.twitter_consumer_secret,
    access_token: Rails.application.secrets.twitter_access_token,
    access_token_secret: Rails.application.secrets.twitter_access_token_secret,
}

TwitterClient.REST = Twitter::REST::Client.new(**twitterSecrets)
TwitterClient.Stream = Twitter::Streaming::Client.new(**twitterSecrets)
