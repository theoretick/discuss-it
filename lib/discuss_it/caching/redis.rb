require 'redis'

module DiscussIt
  module Caching

    # Caching is performed with a simple marshal load/dump to redis.
    # Cache expiration set for 12hr
    module Redis
      def self.fetch(query_url, opts={})
        redis = ::Redis.new

        opts[:source] ||= ['all']
        source = opts[:source].join("_")
        request_cache_key = "#{query_url}_#{source}"

        if redis[request_cache_key]
          puts "[caching] [redis.get] #{request_cache_key}"
          discuss_it = Marshal.load(redis.get(request_cache_key))
        else
          discuss_it = DiscussItApi.new(query_url, opts)
          puts "[caching] [redis.set] #{request_cache_key}"
          redis.setex(request_cache_key, 3600*6, Marshal.dump(discuss_it))
        end

        # Expire the cache if it was a bad request
        redis.del(request_cache_key) unless discuss_it.errors.empty?

        return discuss_it
      end
    end
  end
end
