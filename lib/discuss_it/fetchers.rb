
require 'typhoeus/adapters/faraday'

module DiscussIt

  module Fetcher

    #----------------------------------------------------------------------
    # Formats url, gets response and returns parsed json
    # ABSTRACT ONLY, called w/ RedditFetch, HnFetch, SlashdotFetch
    #----------------------------------------------------------------------
    class BaseFetch

      # returns ruby hash of parsed object
      def parse(response, type='json')
        if type == 'json'
          begin
            return JSON.parse(response)
          # rescue for nil response parsing
          rescue JSON::ParserError => e
            return []
          end
        end
      end

      # ensures url passed to API has http prefix
      def ensure_http(user_string)
        valid_url = user_string
        valid_url = "http://" + user_string unless user_string.match(/(http|https):\/\//)
        return valid_url
      end

      #  makes http call with query_string and returns ruby hash
      def get_response(api_url, query_string)
        begin
          query_url = ensure_http(query_string)

          conn = Faraday.new(url: api_url + query_url) do |faraday|
            faraday.response :logger      # log requests to STDOUT
            faraday.adapter  :typhoeus    # make requests with Typhoeus
            faraday.headers["User-Agent"] = "DiscussItAPI at github.com/discuss-it"
          end

          response = conn.get() do |req|
            req.options[:timeout] = 5           # open/read timeout in seconds
            req.options[:open_timeout] = 2      # connection open timeout in seconds
          end

          return self.parse(response.body)

        # if http://xxx is still invalid url content, then raise error
        # and catch/flash it in controller
        rescue URI::InvalidURIError => e
          raise DiscussIt::UrlError.new

        # if HTTP timeout or general HTTP error, don't break everything
        rescue  Timeout::Error,
                Errno::EINVAL,
                Errno::ECONNRESET,
                EOFError,
                Net::HTTPBadResponse,
                Net::HTTPHeaderSyntaxError,
                Net::ProtocolError => e
          raise DiscussIt::TimeoutError.new
        end

      end

    end





    #----------------------------------------------------------------------
    # - fetches API response from Reddit
    # - provides site-specific details: key-names, howto parse, and urls
    #----------------------------------------------------------------------
    class RedditFetch < BaseFetch

      #  returns big hash of all reddit listings for a query
      def initialize(query_string)

        # TODO: not very DRY, find better solution
        # ALWAYS remove trailing slash before get_response calls
        if query_string.end_with?('/')
          query_url = query_string.chop
        else
          query_url = query_string
        end

        # reddit has no url validation so make EVERY call twice,
        # with and without a trailing slash
        begin
          reddit_raw_a = get_response(api_url, query_url)
          @raw_master = pull_out(reddit_raw_a)
        rescue DiscussIt::TimeoutError => e
          # TODO: add status code for e homepage display 'reddit down'
          @raw_master = []
        end

        # separate rescues to failure is graceful
        begin
          reddit_raw_b = get_response(api_url, query_url + '/')
          # sets master hash of both combined API calls
          @raw_master += pull_out(reddit_raw_b)
        rescue DiscussIt::TimeoutError => e
          # TODO: add status code for e homepage display 'reddit down'
          @raw_master += []
        end
      end

      def api_url
        return 'http://www.reddit.com/api/info.json?url='
      end

      # returns relevant subarray of raw hash listings
      def pull_out(parent_hash)
        return parent_hash["data"]["children"]
      rescue
        return []
      end

      # called in DiscussItApi to build Reddit listings if not already built
      def listings
        return @listings ||= build_all_listings
      end

      def build_listing(parent_hash)
        listing = parent_hash['data']
        return DiscussIt::Listing::RedditListing.new(listing)
      end

      # creates array of listing objects for all responses
      def build_all_listings
        all_listings = []
        @raw_master.each do |listing|
          all_listings << build_listing(listing)
        end
        return all_listings
      end
    end


    #----------------------------------------------------------------------
    # - fetches API response from HackerNews
    # - provides site-specific details: key-names and urls
    #----------------------------------------------------------------------
    class HnFetch < BaseFetch

      #  returns a hash of HN listings for a query
      def initialize(query_string)

        # TODO: not very DRY, find better solution
        # ALWAYS remove trailing slash before get_response calls
        if query_string.end_with?('/')
          query_url = query_string.chop
        else
          query_url = query_string
        end

        begin
          hn_raw = get_response(api_url, query_url + '/')
          @raw_master = pull_out(hn_raw)
        rescue DiscussIt::TimeoutError => e
          # TODO: add status code for e homepage display 'hn down'
          @raw_master = []
        end
      end

      def api_url
        return 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]='
      end

      # returns relevant subarray of raw hash listings
      def pull_out(parent_hash)
        return parent_hash["results"]
      rescue
        return []
      end

      # called in DiscussItApi to build HN listings if not already built
      def listings
        return @listings ||= build_all_listings
      end

      def build_listing(parent_hash)
        listing = parent_hash['item']
        return DiscussIt::Listing::HnListing.new(listing)
      end

      # creates array of listing objects for all responses
      def build_all_listings
        all_listings = []
        @raw_master.each do |listing|
          all_listings << build_listing(listing)
        end
        return all_listings
      end
    end


    #----------------------------------------------------------------------
    # - fetches persistent listings locally from SlashdotPosting,
    # - provides site-specific details: key-names and urls
    #----------------------------------------------------------------------
    class SlashdotFetch < BaseFetch

      #  returns big hash of all slashdot listings for a query
      def initialize(query_string)
        begin
          slashdot_raw = get_response(api_url, query_string)
          @raw_master = slashdot_raw
        rescue DiscussIt::TimeoutError => e
          # TODO: add status code for e homepage display 'slashdot down'
          @raw_master = []
        end
      end

      def api_url
        # FIXME: should this stay around or is it too hacky?
        # if Rails.env.development? || Rails.env.test?
        #   return 'http://localhost:5100/slashdot_postings/search?url='
        # else
          return 'https://slashdot-api.herokuapp.com/slashdot_postings/search?url='
        # end
      end

      # called in DiscussItApi to build Slashdot listings if not already built
      def listings
        return @listings ||= build_all_listings
      end

      def build_listing(parent_hash)
        listing = parent_hash
        return DiscussIt::Listing::SlashdotListing.new(listing)
      end

      # creates array of listing objects for all responses
      def build_all_listings
        all_listings = []
        @raw_master.each do |listing|
          all_listings << build_listing(listing)
        end
        return all_listings
      end

    end

  end

end
