class Friendship

    def initialize(user)
        @user = user
    end

    def follow(friend)
        client.sadd('following:' + @user.id.to_s, friend.id.to_s)
        client.sadd('followers:' + friend.id.to_s, @user.id.to_s)
    end

    def unfollow(friend)
        client.srem('following:' + @user.id.to_s, friend.id.to_s)
        client.srem('followers:' + friend.id.to_s, @user.id.to_s)
    end

    def followers
        client.smembers('followers:' + @user.id.to_s)
    end

    def following
        client.smembers('following:' + @user.id.to_s)
    end

    def following?(friend)
        client.sismember('following:' + @user.id.to_s, friend.id.to_s)
    end

    def follower?(friend)
        client.sismember('followers:' + friend.id.to_s, @user.id.to_s)
    end
    
    def client
        REDIS
    end
end