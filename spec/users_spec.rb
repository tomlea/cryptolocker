require "spec_helper"

describe Cryptolocker::User do
  before :each do
    Cryptolocker.store = {}
  end

  let(:private_key){
    pub, priv = Cryptolocker::RSA.generate_keys
    priv
  }

  let(:public_key){
    OpenSSL::PKey::RSA.new(private_key).public_key.to_pem
  }

  context "with no existing users " do

    describe ".find()" do

      it "returns nil if the user does not exist" do
        Cryptolocker::User.find("tom", "password").should be_nil
      end

      it "returns nil if the password is wrong" do
        p Cryptolocker.public_key
        Cryptolocker::User.create!("tom", "password", "password")
        Cryptolocker::User.find("tom", "not my password").should be_nil
      end

    end

    describe ".create!()" do

      it "rejects when the passwords don't match" do
        lambda{
          Cryptolocker::User.create!("tom", "password", "not the same password")
        }.should raise_exception(Cryptolocker::User::AuthError)
      end

      it "creates a new user when the passwords match" do
        Cryptolocker::User.create!("tom", "password", "password")
        Cryptolocker::User.find("tom", "password").should_not be_nil
      end

      it "when passed the same key, store the key" do
        Cryptolocker.public_key = public_key
        Cryptolocker::User.create!("tom", "password", "password", private_key)
        Cryptolocker::User.find("tom", "password").key.should == private_key
      end

      it "stores the public key" do
        Cryptolocker::User.create!("tom", "password", "password")
        Cryptolocker.public_key.should_not be_nil
      end

    end

  end

  context "with an existing user" do
    let!(:existing_user){ Cryptolocker::User.create!("tom", "password", "password") }

    describe "#grant_to_new_user!()" do

      it "creates a new user, with the same key" do
        new_user = existing_user.grant_to_new_user!("dick", "password13", "password13")
        new_user.key.should == existing_user.key
      end

      it "overrides users that already exist" do
        existing_user.grant_to_new_user!("tom", "password13", "password13")

        Cryptolocker::User.find("tom", "password").should be_nil
        Cryptolocker::User.find("tom", "password13").should_not be_nil
      end

    end

    describe ".create!()" do

      it "refuses to create a new user from scratch" do
        lambda{
          Cryptolocker::User.create!("anotheruser", "password", "password")
        }.should raise_exception(Cryptolocker::User::AuthError)
      end

    end

  end
end
