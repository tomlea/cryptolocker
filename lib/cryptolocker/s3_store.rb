require 'aws/s3'

class Cryptolocker::S3Store
  def initialize(bucket_name)
    @bucket = AWS::S3::Bucket.find(bucket_name)
  end

  def [](key)
    obj = @bucket[key]
    obj && obj.value
  end

  def []=(k,v)
    o = @bucket.new_object
    o.key = k
    o.value = v
    o.store
  end

  def delete(key)
    @bucket[key].delete
  end

  def keys(prefix = "")
    @bucket.objects(:prefix => prefix).map(&:key)
  end
end
