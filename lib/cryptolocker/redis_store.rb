require "redis"

class Cryptolocker::RedisStore
  attr_reader :redis

  def initialize(*args)
    @redis = Redis.new(*args)
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

