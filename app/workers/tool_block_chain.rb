class ToolBlockChain
  include Sidekiq::Worker

  def perform(user_database_id, target_user_name)
    user        = User.find(user_database_id)
    user_auth   = MetaTwitter::Auth.config(user)
    target_user = User.get_from_twitter_name(target_user_name)
    target_list = get_target_list(user: MetaTwitter::Auth.config(user), target: target_user_name)

    block_list = BlockList.make(
      name: "blockchain/on/#{target_user_name}/by/#{user.user_name}",
      private_list: true,
      description: "private reference list for #{user.user_name}'s blockchain on #{target_user_name}",
    )

    parent_report = Report.parse_objects(
      block_list: block_list,
      target: target_user,
      text: "blockchain on #{target_user.account_id}",
      reporter: user,
    )

    for follower_id in target_list
      follower_user = User.update_or_create({id: follower_id})

      follower_report = Report.parse_objects(
        block_list: block_list,
        target: follower_user,
        text: "blockchain on #{target_user.account_id}, chained to #{follower_id}",
        reporter: user,
        parent_id: parent_report.id,
      )

      args = {
        user_id: user_database_id,
        target_id: follower_report.target.id,
        report_id: follower_report.id,
        block_list_id: follower_report.block_list.id,
      }
      PostBlock.perform_async(user_database_id, follower_id, ['create', args,])
    end

    args = {
      user_id: user_database_id,
      target_id: parent_report.target.id,
      report_id: parent_report.id,
      block_list_id: parent_report.block_list.id,
    }
    PostBlock.perform_async(user_database_id, target_user.account_id, ['create', args,])

  end

  def get_target_list(user:, target:)
    target_list = MetaTwitter::ReadFollows.from_followers(user, target: target_user_name )
    target_list = MetaTwitter.remove_follow_from_list(user, target_list, "following")
    target_list = MetaTwitter.remove_blocked_from_list(user, target_list)
    # a filter for removing followers is purposefully omitted here
    # because people will often follow you when they start harassing you
  end

end
