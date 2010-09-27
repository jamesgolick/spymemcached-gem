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

  def set(key, value)
    @client.set(key, 0, value)
  end

  def get(key)
    @client.get(key)
  end

  def flush
    @client.flush
  end
end
