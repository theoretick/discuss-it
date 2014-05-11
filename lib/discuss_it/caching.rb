require 'redis'

module DiscussIt

  class DiscussItApi

    # This method is a drop-in replacement for DiscussItApi.new but w/ caching.
    # caching is performed with a simple marshal load/dump to redis
    #
    # TODO: Move this further into fetchers to cache at a per-response level
    def self.cached_request(query_url, opts={})
      redis = Redis.new

      opts[:source]      ||= ['all']
      request_cache_key = "#{query_url}_#{opts[:source].join("_")}"

      if redis[request_cache_key]
        puts ('*'*80), "[caching] [redis.get] #{request_cache_key}"
        discuss_it = Marshal.load redis.get(request_cache_key)
      else
        discuss_it = self.new(query_url, opts)
        puts ('*'*80), "[caching] [redis.set] #{request_cache_key}"
        redis.set(request_cache_key, Marshal.dump(discuss_it))
        redis.expire(request_cache_key, 3600*6) # cache for 12 hours
      end

      # Expire the cache if it was a bad request
      redis.del(request_cache_key) unless discuss_it.errors.empty?

      return discuss_it
    end
  end
end
