class BlockUserJob
    include Sidekiq::Worker
    sidekiq_options retry: 5, queue: 'block_notifications'

    def perform(user_id, blocked_user_id)
        user = User.where(id: user_id).first
        blocked_user = BlockedUser.where(id: blocked_user_id).first   
        user.block!(blocked_user.twitter_uid)
    end
end