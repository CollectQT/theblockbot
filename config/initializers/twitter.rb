# looks the following in secrets.yml
#
# development:
#   twitter:
#     consumer_key: XXXXXXXXXXXXXXXXXXXXXXXXXXX
#     consumer_secret: XXXXXXXXXXXXXXXXXXXXXXXX
#     access_token: XXXXXXXXXXXXXXXXXXXXXXXXXXX
#     access_token_secret: XXXXXXXXXXXXXXXXXXXX

class TwitterClient
    cattr_accessor :REST, :Stream
end

TwitterClient.REST = Twitter::REST::Client.new(Rails.application.secrets.twitter)
TwitterClient.Stream = Twitter::Streaming::Client.new(Rails.application.secrets.twitter)
