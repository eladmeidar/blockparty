class GetBlockedUsersJob
  include Sidekiq::Job

  sidekiq_options retry: 5, queue: 'blocklists'
  def perform(user_id, cursor = nil)
    user = User.where(id: user_id).first

    if (user)
      next_cursor = cursor || -1
      blocked_response = user.get_blocked_users(cursor: next_cursor).to_h
      next_cursor = blocked_response[:next_cursor]
      blocked_response[:users].each do |blocked_attributes|
        user.add_blocked_user(blocked_attributes)
      end
      if (next_cursor > 0)
        puts "Next cursor: #{next_cursor}"
        GetBlockedUsersJob.perform_in(1.minute, user.id.to_s, next_cursor)
      else
        GetBlockedUsersJob.perform_in(24.hours, user.id.to_s, -1)
      end
    end
  end
end
