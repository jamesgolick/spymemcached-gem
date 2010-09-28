require "java"
require "spymemcached/memcached-2.5.jar"

class Spymemcached
  java_import "net.spy.memcached.MemcachedClient"
  java_import "java.net.InetSocketAddress"

  def initialize(servers)
    @client = MemcachedClient.new(servers.map do |s|
      host, port = s.split(":")
      InetSocketAddress.new(host, port.to_i)
    end)
  end

  def set(key, value, expiration = 0, marshal = true)
    @client.set(key, expiration, marshal(value, marshal))
  end

  def get(key, marshal = true)
    value = @client.get(key)
    marshal && value ? marshal_load(value) : value
  end

  def incr(key, by = 1)
    @client.incr(key, by)
  end

  def decr(key, by = 1)
    @client.decr(key, by)
  end

  def append(key, value)
    @client.append(0, key, value).get
  end

  def prepend(key, value)
    @client.prepend(0, key, value).get
  end

  def multiget(keys, marshal = true)
    Hash[*@client.getBulk(*keys).map { |k,v| [k, marshal ? marshal_load(v) : v] }.flatten]
  end

  def add(key, value, expiration = 0, marshal = true)
    @client.add(key, expiration, marshal(value, marshal)).get
  end

  def del(key)
    @client.delete(key).get
  end

  def flush
    @client.flush
  end

  private
    def marshal(value, marshal)
      marshal ? Marshal.dump(value).to_java_bytes : value.to_s
    end

    def marshal_load(value)
      Marshal.load(String.from_java_bytes(value))
    end
end
