class CreateBlock
  include Sidekiq::Worker

  def perform(user_id, report_id)
    user = User.find(user_id)
    report = Report.find(report_id)
    target = report.target.account_id.to_i

    # dont block users that our client user is following
    if ReadFollowing.new.read(user.id, target)
        return
    end

    # dont block users that are already blocked
    if ReadBlock.new.read(user.id, target)
        return
    end

    # if the user does not want to block followers...
    if user.dont_block_followers
      # ...then dont block followers
      if ReadFollower.new.read(user.id target)
        return
      end
    end

    PostBlock.perform_async(user.id, report.id)
    user.update_log("[ADD] Blocking user #{report.target.user_name}")
  end
end
