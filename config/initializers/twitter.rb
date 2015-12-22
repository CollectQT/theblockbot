# looks the following in secrets.yml
#
# development:
#   consumer_key: XXXXXXXXXXXXXXXXXXXXXXXXXXX
#   consumer_secret: XXXXXXXXXXXXXXXXXXXXXXXX
#   access_token: XXXXXXXXXXXXXXXXXXXXXXXXXXX
#   access_token_secret: XXXXXXXXXXXXXXXXXXXX

class TwitterClient
    cattr_accessor :REST, :Stream
end

twitterSecrets = {
    consumer_key: Rails.application.secrets.consumer_key,
    consumer_secret: Rails.application.secrets.consumer_secret,
    access_token: Rails.application.secrets.access_token,
    access_token_secret: Rails.application.secrets.access_token_secret,
}

TwitterClient.REST = Twitter::REST::Client.new(**twitterSecrets)
TwitterClient.Stream = Twitter::Streaming::Client.new(**twitterSecrets)
