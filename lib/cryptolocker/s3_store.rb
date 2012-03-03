require 'aws/s3'

class Cryptolocker::S3Store
  include AWS::S3

  attr_reader :bucket_name

  def initialize(bucket_name)
    @bucket_name = bucket_name
  end

  def [](key)
    obj = S3Object.find(key, bucket_name)
    obj && obj.value
  end

  def []=(k,v)
    S3Object.store(k, v, bucket_name)
  end

  def delete(key)
    S3Object.delete(key, bucket_name)
  end

  def keys(prefix = "")
    Bucket.objects(bucket_name, :prefix => prefix).map(&:key)
  end
end
