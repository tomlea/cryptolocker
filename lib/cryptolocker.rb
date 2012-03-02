require "rubygems"
require "bundler/setup"

Bundler.require(:default)

require "openssl"

module Cryptolocker
  attr_accessor :store

  require "openssl"

  def public_key
    store["public_key"]
  end

  def public_key=(v)
    store["public_key"] = v
  end

  def initial_setup_mode?
    !public_key
  end

  extend self
end

require "cryptolocker/aes"
require "cryptolocker/rsa"
require "cryptolocker/user"

