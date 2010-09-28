require "active_support"
require "spymemcached"

module ActiveSupport
  module Cache
    class SpymemcachedStore < Store
      attr_reader :addresses

      def initialize(*addresses)
        addresses.flatten!

        @addresses = addresses
        @cache     = Spymemcached.new(@addresses)
      end

      def read(key, options = nil)
        super
        @cache.get(key, (options && options[:raw]))
      end

      # Set the key to the given value. Pass :unless_exist => true if you want to
      # skip setting a key that already exists.
      def write(key, value, options = nil)
        super
        method = unless_exist?(options) ? :add : :set
        @cache.send(method, key, value, expiry(options).to_i, (options && options[:raw]))
      end

      def delete(key, options = nil)
        super
        @cache.del(key)
      end

      def exist?(key, options = nil)
        !read(key, options).nil?
      end

      def increment(key, amount=1)
        log 'incrementing', key, amount
        @cache.incr(key, amount)
      end

      def decrement(key, amount=1)
        log 'decrementing', key, amount
        @cache.decr(key, amount)
      end

      def delete_matched(matcher, options = nil)
        super
        raise NotImplementedError
      end

      def clear
        @cache.flush
      end

      private
        def unless_exist?(options)
          options.respond_to?(:[]) && options[:unless_exist]
        end

        def expiry(options)
          options.respond_to?(:[]) && options[:expires_in] ? options[:expires_in] : 0
        end
    end
  end
end
