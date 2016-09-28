class PostBlock
  include Sidekiq::Worker

  sidekiq_retry_in do |count|
    # 15min * 60sec/min = 900sec
    900 * (count + 1)
  end

  def perform(user_database_id, target_account_id, callback=nil)
    block(user_database_id, target_account_id)
    Utils.send(Block, callback)
  end

  def block(user_database_id, target_account_id)
    begin
      user = MetaTwitter::Auth.config( User.find(user_database_id) )
      user.block(target_account_id.to_i)
    rescue Twitter::Error::NotFound
      Rails.logger.info { "Twitter account with id #{target_account_id} no longer exists" }
    end
  end

end
