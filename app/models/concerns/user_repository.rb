class UserRepository

    def self.add_username(username)
        search_string = ''
        username.split('').each do |char|
            search_string += char
            if search_string.length >= 3
                REDIS.sadd("username:#{search_string.downcase}", username)
            end
        end
        true
    end

    def self.search(query)
        if query.length < 3
            return {usernames: [], error: 'query string must be longer than 3 chars'}
        else
            return {usernames: REDIS.smembers("username:#{query.downcase}")}
        end
    end
    def self.client
        REDIS
    end
end