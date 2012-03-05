require "openssl"
class Cryptolocker::RSA
  KEY_LEN = 4096
  def key_byte_length
    KEY_LEN/8
  end

  def self.generate_keys
    new_key = OpenSSL::PKey::RSA.generate( KEY_LEN )
    return [new_key.public_key.to_pem, new_key.to_pem]
  end

  def self.valid_pair?(pub, priv)
    pub = new(pub)
    priv = new(priv)
    priv.decrypt(pub.encrypt("HELLO")) == "HELLO"
  rescue OpenSSL::PKey::RSAError, OpenSSL::Cipher::CipherError
    false
  end

  def initialize(key)
    raise OpenSSL::PKey::RSAError, "Key must be a string" unless key.is_a? String
    @key = OpenSSL::PKey::RSA.new(key)
  end

  def encrypt(value)
    one_time_key = Cryptolocker::AES.generate_random_key
    encrypted_key = @key.public_encrypt(one_time_key)
    encrypted_key + Cryptolocker::AES.encrypt(value, one_time_key)
  end

  def decrypt(value)
    encrypted_key = value[0...key_byte_length]
    data = value[key_byte_length..-1]
    one_time_key = @key.private_decrypt(encrypted_key)
    Cryptolocker::AES.decrypt(data, one_time_key)
  end

end
