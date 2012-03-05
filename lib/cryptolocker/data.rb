module Cryptolocker::Data
  def receive(io)
    data = io.read
    encypted_data = Cryptolocker::RSA.new(Cryptolocker.public_key).encrypt(data)
    ident = Digest::SHA1.hexdigest(data)
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
