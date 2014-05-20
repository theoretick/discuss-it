
require 'typhoeus'
require 'json'
require 'redis'
require_relative 'discuss_it'

# For loading redis with reddit subscriber counts
class SubscriberFetcher

  # namespace 1 for storing subreddits and subscribers
  def perform
    @redis = Redis.new(:db => 1)
    10.times do |n|
      fetch_popular_subs
      sleep 2 # stay within Reddit API limits
    end
  end

  def fetch_popular_subs
    request = Typhoeus::Request.new(
      popular_subs_url,
      method: :get,
      headers: {
        "User-Agent" => "DiscussItAPI #{DiscussIt::VERSION} at github.com/discuss-it"
      }
    )
    request.on_complete do |response|
      if response.success?
        json = JSON.parse(request.response.body)
        parse_response(json)
      else
        p "[loader] HTTP request failed: #{response.code.to_s}"
      end
    end

    request.run
  end

  def parse_response(json_data)
    @last_fetched_sub = json_data['data']['after']
    json_data['data']['children'].each do |raw_sub|
      persist_sub! raw_sub
    end
  end

  def persist_sub!(raw_sub)
    name = raw_sub['data']['display_name'].downcase
    count = raw_sub['data']['subscribers']
    redis_key = "reddit:#{name}:count"

    puts "[loader] [redis.set] #{redis_key} has #{count} subscribers"
    @redis.set(redis_key, count)
  end

  def popular_subs_url
    url = "http://www.reddit.com/subreddits/popular.json?limit=100"
    if @last_fetched_sub
      url.concat "&after=#{@last_fetched_sub}"
    else
      url
    end
  end
end

# For flushing redis db, mostly for debugging/testing
class SubscriberFlush
  def perform
    @redis = Redis.new(:db => 1)
    @redis.flushdb
  end
end