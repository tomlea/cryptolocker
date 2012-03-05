require "redis"

class Cryptolocker::RedisStore
  attr_reader :redis

  def initialize(redis_url)
    @redis = Redis.new(redis_url)
  end

  def [](key)
    redis.get(key)
  end

  def []=(key,value)
    redis.set(key, value)
  end

  def delete(key)
    redis.del(key)
  end

  def keys(prefix = "")
    redis.keys("#{prefix}*")
  end
end

