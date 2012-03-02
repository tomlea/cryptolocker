module Cryptolocker::AES
  CIPHER = 'aes-256-cbc'

  def encrypt(data, key)
    return data if data.nil? or data.empty?

    cipher = OpenSSL::Cipher.new(CIPHER)
    cipher.encrypt
    cipher.key = key
    cipher.iv = iv = cipher.random_iv
    ciphertext = cipher.update(data)
    ciphertext << cipher.final
    return iv + ciphertext
  end

  def decrypt(data, key)
    return data if data.nil? or data.empty?

    cipher = OpenSSL::Cipher.new(CIPHER)
    iv = data[0, cipher.iv_len]
    ciphertext = data[cipher.iv_len..-1]
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

  def key_from_password(password)
    OpenSSL::Digest::SHA512.new(password).digest[0..key_len]
  end

  def key_len
    OpenSSL::Cipher.new(CIPHER).key_len
  end

  extend self
end