require "rubygems"
require "bundler/setup"
Bundler.require(:default, :test)

require "cryptolocker"
Cryptolocker::RSA.send(:remove_const, :KEY_LEN)
Cryptolocker::RSA::KEY_LEN = 1024
