class Cryptolocker::User
  AES = Cryptolocker::AES

  def self.create!(username, password, password_confirmation, shared_key = nil)
    raise Cryptolocker::User::AuthError, "Passwords do not match" unless password_confirmation == password
    raise Cryptolocker::User::AuthError, "already secured, get someone else to grant you access" if shared_key.nil? and not Cryptolocker.initial_setup_mode?

    if shared_key.nil?
      pub, priv = Cryptolocker::RSA.generate_keys
      shared_key = priv
      Cryptolocker.public_key = pub
    end


    personal_key = AES.key_from_password(password, Cryptolocker.public_key)

    Cryptolocker.store["users.#{username}.key"] = AES.encrypt(shared_key, personal_key)

    find(username, password)
  end

  def self.all_names
    if Cryptolocker.store.is_a? Cryptolocker::S3Store
      Cryptolocker.store.keys("users.")
    else
      Cryptolocker.store.keys
    end.grep(/^users\.[^\.]+\.key$/).map{|k| k.split('.', 3)[1] }
  end

  def self.delete(username)
    raise Cryptolocker::User::AuthError, "You can't delete the admin user" if username == "admin"

    Cryptolocker.store.delete("users.#{username}.key")
  end

  def self.valid_username_and_password?(username, password)
    personal_key = AES.key_from_password(password, Cryptolocker.public_key)
    private_key =  AES.decrypt(Cryptolocker.store["users.#{username}.key"], personal_key)
    Cryptolocker::RSA.valid_pair?(Cryptolocker.public_key, private_key)
  rescue OpenSSL::Cipher::CipherError
  end

  def self.find(username, password)
    new(username, password) if valid_username_and_password?(username, password)
  end

  attr_reader :username, :password

  def initialize(username, password)
    @username, @password = username, password
  end

  def decrypt(value)
    @my_key ||= AES.key_from_password(password, Cryptolocker.public_key)
    AES.decrypt(value, @my_key)
  end

  def key
    decrypt(Cryptolocker.store["users.#{username}.key"])
  end

  def grant_to_new_user!(name, password, password_confirmation)
    self.class.create!(name, password, password_confirmation, key)
  end
end

class Cryptolocker::User::AuthError < RuntimeError
end
