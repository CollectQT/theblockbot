# from https://github.com/resque/resque#overview
class SendBlock
  include Sidekiq::Worker

  def perform(name)
    TwitterClient.REST.update(name)
  end
end
