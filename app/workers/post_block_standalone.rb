class PostBlockStandalone
  include Sidekiq::Worker

  sidekiq_retry_in do |count|
    # 15min * 60sec/min = 900sec
    900 * (count + 1)
  end

  def perform(user_database_id, target_account_id)
    user = MetaTwitter::Auth.config( User.find(user_database_id) )
    user.block(target_account_id)
  end

end
