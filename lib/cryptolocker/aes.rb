require 'pbkdf2'

module Cryptolocker::AES
  KEY_LENGTH = 256
  CIPHER = "aes-#{KEY_LENGTH}-cbc"

  def encrypt(data, key)
    return data if data.nil? or data.empty?

    cipher = OpenSSL::Cipher.new(CIPHER)
    cipher.encrypt
    cipher.key = key
    cipher.iv = iv = cipher.random_iv
    ciphertext = cipher.update(data)
    ciphertext << cipher.final
    return [iv, ciphertext].pack("a#{cipher.iv_len}a*")
  end

  def decrypt(data, key)
    return data if data.nil? or data.empty?

    cipher = OpenSSL::Cipher.new(CIPHER)
    iv, ciphertext = data.unpack("a#{cipher.iv_len}a*")
    cipher.decrypt
    cipher.key = key
    cipher.iv = iv
    plaintext = cipher.update(ciphertext)
    plaintext << cipher.final
    return plaintext
  end

  def generate_random_key
    OpenSSL::Cipher.new(CIPHER).random_key
  end

  def key_from_password(password, salt)
    PBKDF2.new{|generator| 
      generator.password = password
      generator.salt = salt
      generator.iterations = 1_000
      generator.key_length = KEY_LENGTH
    }.bin_string
  end

  def key_len
    OpenSSL::Cipher.new(CIPHER).key_len
  end

  extend self
end
