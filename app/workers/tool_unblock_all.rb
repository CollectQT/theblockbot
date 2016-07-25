class ToolUnblockAll
  include Sidekiq::Worker

  def perform(user_database_id)
    block_ids = MetaTwitter::BlockIds.read(
      MetaTwitter::Auth.from_database_id(user_database_id)
    )

    for target_id in block_ids
      PostUnblock.perform_async(user_database_id, target_id)
    end
  end

end
