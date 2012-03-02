require "spec_helper"

describe Cryptolocker::RSA do
  describe "#encrypt and #decrypt" do
    attr_reader :pusher, :reader
    before do
      pub, priv = Cryptolocker::RSA.generate_keys
      @pusher = Cryptolocker::RSA.new(pub)
      @reader = Cryptolocker::RSA.new(priv)
    end

    let(:long_string){
      "Hello "*1000
    }

    it "encrypts and decrypts large strings with pub/priv pair" do
      enc = pusher.encrypt(long_string)
      enc.should_not include(long_string)
      reader.decrypt(enc).should == long_string
    end

    it "fails to decrypt with the public key" do
      enc = pusher.encrypt(long_string)
      enc.should_not include(long_string)

      lambda{
        pusher.decrypt(enc)
      }.should raise_exception(OpenSSL::PKey::RSAError, /private key needed/)
    end
  end

  describe ".generate_keys" do
    it "returns 2 strings" do
      k,v = Cryptolocker::RSA.generate_keys
      k.should be_a(String)
      v.should be_a(String)
    end

    it "returns different keys each time" do
      k1,v1 = Cryptolocker::RSA.generate_keys
      k2,v2 = Cryptolocker::RSA.generate_keys
      k1.should_not == k2
      v1.should_not == v2
    end
  end

  describe ".valid_pair?(pub, priv)" do
    it "returns true when the keys are a pair" do
      pub, priv = Cryptolocker::RSA.generate_keys
      Cryptolocker::RSA.valid_pair?(pub, priv).should be_true
    end

    it "returns false when the keys are not a pair" do
      pub, _  = Cryptolocker::RSA.generate_keys
      _, priv = Cryptolocker::RSA.generate_keys
      Cryptolocker::RSA.valid_pair?(pub, priv).should_not be_true
    end
  end

end
