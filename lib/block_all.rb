#!/usr/bin/env ruby

require 'yaml'
require 'dotenv'
require 'twitter'
require 'optparse'


class BlockAll

  def initialize
    Dotenv.load
    @Twitter = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['twitter_consumer_key']
      config.consumer_secret     = ENV['twitter_consumer_secret']
      config.access_token        = ENV['twitter_access_token']
      config.access_token_secret = ENV['twitter_access_token_secret']
    end
  end

  def block_followers(name)
    puts "would block all of #{name}\'s followers"
    puts @Twitter.user.name
  end

  def undo
    puts 'would undo the block command'
    puts @Twitter.user.name
  end

end


if __FILE__ == $0
  OptionParser.new do |opts|

    opts.banner = "Usage: ruby lib/block_all.rb [option]"

    opts.on('-f', '--followers NAME', 'Person to block') do |name|
      BlockAll.new.block_followers(name)
    end

    opts.on('-u', '--undo', 'Undo\'s block all') do
      BlockAll.new.undo()
    end

    ARGV << '-h' if ARGV.empty?
    opts.on('-h', '--help', 'Prints this help') do
      puts "

Setup:
  git clone http://gitlab.com/collectqt/theblockbot
  cd theblockbot
  bundle install
  subl .env
      twitter_consumer_key=XXXXXXXXXXXXXXXXXXXXXXXX
      twitter_consumer_secret=XXXXXXXXXXXXXXXXXXXXX
      twitter_access_token=XXXXXXXXXXXXXXXXXXXXXXXX
      twitter_access_token_secret=XXXXXXXXXXXXXXXXX


#{opts}
      "
      exit
    end

  end.parse!
end
