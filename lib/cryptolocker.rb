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

  module Data
    def receive(io)
      encypted_data = Cryptolocker::RSA.new(Cryptolocker.public_key).encrypt(io.read)
      ident = Digest::MD5.hexdigest([Time.now, Time.now.usec, Process.pid].join(":"))
      Cryptolocker.store["data.#{ident}"] = encypted_data
      ident
    end

    def read(ident, user)
      if data = Cryptolocker.store["data.#{ident}"]
        Cryptolocker::RSA.new(user.key).decrypt(data)
      end
    end

    extend self
  end

  extend self
end

require "cryptolocker/aes"
require "cryptolocker/rsa"
require "cryptolocker/user"

