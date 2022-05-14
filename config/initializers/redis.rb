
if Rails.env.development?
    REDIS = Redis.new(:host => 'localhost', :port => 6379)
else
    REDIS = Redis.new(:url => ENV["REDIS_URL"])
end
