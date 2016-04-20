class ReadBlock
  include Sidekiq::Worker

  def perform(user_id, target_id)
    Rails.cache.fetch("#{user_id}/#{target_id}/block", expires_in: 1.days) do
      user = TwitterClient.user(User.find(user_id))
      return user.block?(target_id)
    end
  end

end
