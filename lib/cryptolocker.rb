require "rubygems"
require "bundler/setup"

Bundler.require(:default)

require "openssl"

module Cryptolocker
  attr_reader :store

  def store=(v)
    @store = v
    @public_key = nil
  end

  autoload :S3Store, "cryptolocker/s3_store"
  autoload :RedisStore, "cryptolocker/redis_store"

  require "openssl"

  def public_key
    @public_key ||= store["public_key"]
  end

  def public_key=(v)
    @public_key = store["public_key"] = v
  end

  def initial_setup_mode?
    !public_key
  end

  extend self
end

require "cryptolocker/aes"
require "cryptolocker/rsa"
require "cryptolocker/user"
require "cryptolocker/data"

