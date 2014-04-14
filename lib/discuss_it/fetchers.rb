
require 'typhoeus/adapters/faraday'

module DiscussIt

  module Fetcher

    #----------------------------------------------------------------------
    # Formats url, gets response and returns parsed json
    # ABSTRACT ONLY, called w/ RedditFetch, HnFetch, SlashdotFetch
    #----------------------------------------------------------------------
    class BaseFetch

      attr_reader :errors

      def initialize
        @errors = []
      end

      # Public: makes http req with query_string.
      #
      # api_url      - base url of current discussion site to be queried.
      # query_string - user-submitted url to find discussions about.
      #
      # Examples
      #
      #   get_response('http://www.reddit.com/api/info.json?url=',
      #                'http://example.com')
      #   # => { listing1: {...},
      #          listing2: {...},
      #          ...}
      #
      #   get_response('https://slashdot-api.herokuapp.com/slashdot_postings/search?url=',
      #                'http://example.com')
      #   # => { listing1: {...},
      #          listing2: {...},
      #          ...}
      #
      # Returns parsed hash of matching discussions from external APIs
      def get_response(api_url, query_string)
        begin
          query_url = ensure_http(query_string)
          fetcher_url = api_url + query_url

          conn = Faraday.new(url: fetcher_url) do |faraday|
            faraday.response :logger      # log requests to STDOUT
            faraday.adapter  :typhoeus    # make requests with Typhoeus
            faraday.headers["User-Agent"] = "DiscussItAPI #{VERSION} at github.com/discuss-it"
          end

          response = conn.get() do |req|
            req.options[:timeout] = 4           # open/read timeout in seconds
            req.options[:open_timeout] = 2      # connection open timeout in seconds
          end

          return self.parse(response.body)

        # if HTTP timeout or general HTTP error, don't break everything
        rescue  Timeout::Error,
                Errno::EINVAL,
                Errno::ECONNRESET,
                EOFError,
                Net::HTTPBadResponse,
                Net::HTTPHeaderSyntaxError,
                Net::ProtocolError,
                Faraday::Error::TimeoutError => e
          raise DiscussIt::TimeoutError.new
        end

      end

      # Private: parses HTTP responses into something usable.
      #
      # response - http_response object to be parsed.
      # type     - type of response object. (default: 'json')
      #
      # Examples
      #
      #   parse(some_http_response_object, 'json')
      #   # => {   foo: 'bar',
      #         chunky: 'bacon'}
      #
      # Returns ruby hash.
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

      # Private: ensures url passed to API has http prefix.
      #
      # user_string - user-submitted string to be checked for prefix.
      #
      # Examples
      #
      #   ensure_http('example.com')
      #   # => 'http://example.com'
      #
      #   ensure_http('http://example.com')
      #   # => 'http://example.com'
      #
      #   ensure_http('https://example.com')
      #   # => 'https://example.com'
      #
      # Returns a string with 'http://' prefix if not already present
      def ensure_http(user_string)
        valid_url = user_string
        valid_url = "http://" + user_string unless user_string.match(/(http|https):\/\//)
        return valid_url
      end

    end


    #----------------------------------------------------------------------
    # - fetches API response from Reddit
    # - provides site-specific details: key-names, howto parse, and urls
    #----------------------------------------------------------------------
    class RedditFetch < BaseFetch

      # Public: Calls reddit API to search for query url.
      #
      # Performs TWO fetches: Due to Reddit's lack of URL
      # validation, a query for 'http://example.com' and
      # 'http://example.com/' (with trailing slash) will return two diff
      # datasets. Therefore, all urls are first stripped of trailing and
      # then two separate Reddit queries are made, with and without '/'.
      #
      # Includes separate rescues to ensure failure is graceful.
      #
      # query_url - user-submitted url to find discussions about.
      #
      # Examples
      #
      #   reddit_results = RedditFetch.new('example.com')
      #
      # Returns nothing.
      def initialize(query_url)
        @errors = []

        # API call #1 (no trailing slash)
        begin
          reddit_raw_a = get_response(api_url, query_url)
          @raw_master = pull_out(reddit_raw_a)
        rescue DiscussIt::TimeoutError => e
          # TODO: add status code for e homepage display 'reddit down'
          @raw_master = []
          @errors << e
        end

        # API call #2 (with trailing slash)
        begin
          reddit_raw_b = get_response(api_url, query_url + '/')
          # sets master hash of both combined API calls
          @raw_master += pull_out(reddit_raw_b)
        rescue DiscussIt::TimeoutError => e
          # TODO: add status code for e homepage display 'reddit down'
          @raw_master += []
          @errors << e
        end
      end

      # Public: Return Reddit listings or build if not already built.
      #
      # Called in DiscussItApi.
      #
      # Returns Array of Listing instances.
      def listings
        return @listings ||= build_all_listings
      end

      def api_url
        return 'http://www.reddit.com/api/info.json?url='
      end

      # Private: selects relevant subarray of raw hash listings
      # Returns Array of raw listings
      def pull_out(parent_hash)
        return parent_hash["data"]["children"]
      rescue
        return []
      end

      # Private: creates array of listing objects for all responses.
      # returns Array of Listing instances.
      def build_all_listings
        all_listings = []
        @raw_master.each do |listing|
          all_listings << build_listing(listing)
        end
        return all_listings
      end

      # Private: Takes raw hash and creates Listing instance from it
      def build_listing(parent_hash)
        listing = parent_hash['data']
        listing['site'] = 'Reddit'
        listing['location'] = 'http://www.reddit.com' + listing['permalink']
        reddit_listing =  DiscussIt::Listing::RedditListing.new(listing)
        reddit_listing.ranking
        return reddit_listing
      end

    end


    #----------------------------------------------------------------------
    # - fetches API response from HackerNews
    # - provides site-specific details: key-names and urls
    #----------------------------------------------------------------------
    class HnFetch < BaseFetch

      # Public: Calls HackerNews API to search for query url.
      #
      # query_url - user-submitted url to find discussions about.
      #
      # Examples
      #
      #   hn_results = HnFetch.new('example.com')
      #
      # Returns nothing.
      def initialize(query_url)
        @errors = []
        begin
          hn_raw = get_response(api_url, query_url + '/')
          @raw_master = pull_out(hn_raw)
        rescue DiscussIt::TimeoutError => e
          # TODO: add status code for e homepage display 'hn down'
          @raw_master = []
          @errors << e
        end
      end

      # Public: Return Hn listings or build if not already built.
      #
      # Called in DiscussItApi.
      #
      # Returns Array of Listing instances.
      def listings
        return @listings ||= build_all_listings
      end

      def api_url
        return 'http://hn.algolia.io/api/v1/search?tags=story&query='
      end

      # Private: selects relevant subarray of raw hash listings
      # Returns Array of raw listings
      def pull_out(parent_hash)
        return parent_hash["hits"]
      rescue
        return []
      end

      # Private: creates array of listing objects for all responses.
      # returns Array of Listing instances.
      def build_all_listings
        all_listings = []
        @raw_master.each do |listing|
          all_listings << build_listing(listing)
        end
        return all_listings
      end

      # Private: Takes raw hash and creates Listing instance from it
      def build_listing(parent_hash)
        listing = parent_hash
        listing['site'] = 'HackerNews'
        listing['location'] = 'http://news.ycombinator.com/item?id=' + listing['objectID'].to_s
        hn_listing = DiscussIt::Listing::HnListing.new(listing)
        hn_listing.ranking
        return hn_listing
      end
    end


    #----------------------------------------------------------------------
    # - fetches persistent listings locally from SlashdotPosting,
    # - provides site-specific details: key-names and urls
    #----------------------------------------------------------------------
    class SlashdotFetch < BaseFetch

      # Public: Calls Custom Slashdot API to search for query url.
      #
      # query_url - user-submitted url to find discussions about.
      #
      # Examples
      #
      #   slashdot_results = SlashdotFetch.new('example.com')
      #
      # Returns nothing.
      def initialize(query_url)
        @errors = []
        begin
          slashdot_raw = get_response(api_url, query_url)
          @raw_master = slashdot_raw
        rescue DiscussIt::TimeoutError => e
          # TODO: add status code for e homepage display 'slashdot down'
          @errors << e
          @raw_master = []
        end
      end

      # Public: Return Slashdot listings or build if not already built.
      #
      # Called in DiscussItApi.
      #
      # Returns Array of Listing instances.
      def listings
        return @listings ||= build_all_listings
      end

      def api_url
        # FIXME: should this stay around or is it too hacky?
        # if Rails.env.development? || Rails.env.test?
        #   return 'http://localhost:5100/slashdot_postings/search?url='
        # else
          return 'https://slashdot-api.herokuapp.com/slashdot_postings/search?url='
        # end
      end

      # Private: creates array of listing objects for all responses.
      # returns Array of Listing instances.
      def build_all_listings
        all_listings = []
        @raw_master.each do |listing|
          all_listings << build_listing(listing)
        end
        return all_listings
      end

      # Private: Takes raw hash and creates Listing instance from it
      def build_listing(parent_hash)
        location = parent_hash['permalink']
        comment_count = parent_hash['comment_count']
        parent_hash.delete('permalink')
        parent_hash.delete('comment_count')
        listing  = parent_hash

        listing['site'] = 'Slashdot'
        listing['location'] = location
        listing['num_comments'] = comment_count
        slash_listing = DiscussIt::Listing::SlashdotListing.new(listing)
        slash_listing.ranking
        return slash_listing
      end

    end

  end

end
