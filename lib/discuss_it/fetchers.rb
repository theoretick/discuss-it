
require 'typhoeus'

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
        query_url   = ensure_http(query_string)
        fetcher_url = api_url + query_url

        request = Typhoeus::Request.new(
          fetcher_url,
          method: :get,
          headers: {
            "User-Agent" => "DiscussItAPI #{VERSION} at github.com/discuss-it"
          }
        )

        request.on_complete do |response|
          puts "[fetcher] [#{source_name}] - #{response.code} for '#{query_url}'"
          if response.success?
            # hurrah!
          elsif response.timed_out?
            @errors << DiscussIt::TimeoutError.new("Resource timed out")
          elsif response.code == 0
            # Could not get an http response, something's wrong.
            @errors << StandardError.new(response.return_message)
          elsif [404, 503, 504].include? response.code
            @errors << DiscussIt::SourceDownError.new("#{source_name} appears to be down")
          else
            @errors << StandardError.new("HTTP request failed: #{response.code.to_s}")
          end
        end
        request.run

        parse(request.response.body)
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
            JSON.parse(response)
          rescue JSON::ParserError => e
            []
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
        reddit_raw_a = get_response(api_url, query_url)
        @raw_master = pull_out(reddit_raw_a)

        # API call #2 (with trailing slash)
        reddit_raw_b = get_response(api_url, query_url + '/')
        # sets master hash of both combined API calls
        @raw_master += pull_out(reddit_raw_b)
      end

      # Public: Return Reddit listings or build if not already built.
      #
      # Called in DiscussItApi.
      #
      # Returns Array of Listing instances.
      def listings
        @listings ||= build_all_listings
      end

      def api_url
        'http://www.reddit.com/api/info.json?url='
      end

      # Private: selects relevant subarray of raw hash listings
      # Returns Array of raw listings
      def pull_out(parent_hash)
        parent_hash["data"]["children"] || []
      end

      # Private: creates array of listing objects for all responses.
      # returns Array of Listing instances.
      def build_all_listings
        @raw_master.reduce([]) do |accum, listing|
          accum << build_listing(listing)
        end
      end

      # Private: Takes raw hash and creates Listing instance from it
      def build_listing(parent_hash)
        listing = parent_hash['data']
        listing['site'] = source_name
        listing['location'] = 'http://www.reddit.com' + listing['permalink']
        reddit_listing =  DiscussIt::Listing::RedditListing.new(listing)
        reddit_listing.ranking
        return reddit_listing
      end

      def source_name
        'Reddit'
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
        full_query = "%22#{query_url}%22"
        hn_raw = get_response(api_url, full_query)
        @raw_master = pull_out(hn_raw)
      end

      # Public: Return Hn listings or build if not already built.
      #
      # Called in DiscussItApi.
      #
      # Returns Array of Listing instances.
      def listings
        @listings ||= build_all_listings
      end

      def api_url
        'http://hn.algolia.com/api/v1/search?restrictSearchableAttributes=url&query='
      end

      # Private: selects relevant subarray of raw hash listings
      # Returns Array of raw listings
      def pull_out(parent_hash)
        parent_hash["hits"] || []
      end

      # Private: creates array of listing objects for all responses.
      # returns Array of Listing instances.
      def build_all_listings
        @raw_master.reduce([]) do |accum, listing|
          accum << build_listing(listing)
        end
      end

      # Private: Takes raw hash and creates Listing instance from it
      def build_listing(parent_hash)
        listing = parent_hash
        listing['site'] = source_name
        listing['location'] = 'http://news.ycombinator.com/item?id=' + listing['objectID'].to_s
        hn_listing = DiscussIt::Listing::HnListing.new(listing)
        hn_listing.ranking
        return hn_listing
      end

      def source_name
        'HackerNews'
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

        slashdot_raw = get_response(api_url, query_url)
        @raw_master = slashdot_raw
      end

      # Public: Return Slashdot listings or build if not already built.
      #
      # Called in DiscussItApi.
      #
      # Returns Array of Listing instances.
      def listings
        @listings ||= build_all_listings
      end

      def api_url
        'https://slashdot-api.herokuapp.com/slashdot_postings/search?url='
      end

      # Private: creates array of listing objects for all responses.
      # returns Array of Listing instances.
      def build_all_listings
        @raw_master.reduce([]) do |accum, listing|
          accum << build_listing(listing)
        end
      end

      # Private: Takes raw hash and creates Listing instance from it
      def build_listing(parent_hash)
        location = parent_hash['permalink']
        comment_count = parent_hash['comment_count']
        parent_hash.delete('permalink')
        parent_hash.delete('comment_count')
        listing  = parent_hash

        listing['site'] = source_name
        listing['location'] = location
        listing['num_comments'] = comment_count
        slash_listing = DiscussIt::Listing::SlashdotListing.new(listing)
        slash_listing.ranking
        return slash_listing
      end

      def source_name
        'Slashdot'
      end
    end
  end
end
