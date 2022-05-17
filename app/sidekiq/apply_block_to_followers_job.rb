class ApplyBlockToFollowersJob
    include Sidekiq::Job
    sidekiq_options retry: 5, queue: 'block_notifications'

    def perform(user_id, blocked_user_id)
        user = User.where(id: user_id).first
        blocked_user = BlockedUser.where(id: blocked_user_id).first

        if (user && blocked_user)
            user.followers.each do |follower_id|
                BlockUserJob.perform_async(follower_id, blocked_user_id)
            end
        end
    end
end  