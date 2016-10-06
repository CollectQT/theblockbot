class CreateBlock
  include Sidekiq::Worker

  def perform(user_database_id, target_account_id)
    # user_model = User.find(user_database_id)
    # user_auth  = MetaTwitter::Auth.config(user_model)
    # report = Report.find(report_id)
    # target = report.target.account_id.to_i

    # # dont block users that our client user is following
    # MetaTwitter.get_following?(user_auth, target) ? return : nil

    # # dont block users that are already blocked
    # MetaTwitter.get_blocked?(user_auth, target) ? return : nil

    # # if the user does not want to block followers...
    # if user_model.dont_block_followers
    #   # ...then dont block followers
    #   MetaTwitter.get_follower?(user_auth, target) ? return : nil
    # end

    # args = {
    #   user_id: user_database_id,
    #   target_id: report.target.id,
    #   report_id: report.id,
    #   block_list_id: report.block_list.id,
    # }
    # PostBlock.perform_async(user_database_id, target_account_id, ['create', args,])
  end
end
