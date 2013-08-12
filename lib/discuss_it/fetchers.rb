
# TODO: currently redundant. figure out default_timeout
require 'httparty'
require 'json'

module DiscussIt

  module Fetcher

    #----------------------------------------------------------------------
    # - fetches API response from Reddit
    # - provides site-specific details: key-names, howto parse, and urls
    #----------------------------------------------------------------------
    class RedditFetch

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
          reddit_raw_a = Fetch.get_response(api_url, query_url)
          @raw_master = pull_out(reddit_raw_a)
        rescue DiscussIt::TimeoutError => e
          # TODO: add status code for e homepage display 'reddit down'
          @raw_master = []
        end

        # separate rescues to failure is graceful
        begin
          reddit_raw_b = Fetch.get_response(api_url, query_url + '/')
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
        return DiscussIt::Listings::RedditListing.new(listing)
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
    class HnFetch

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
          hn_raw = Fetch.get_response(api_url, query_url + '/')
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
        # FIXME: up one level in the hash is weighting data for HN
        listing = parent_hash['item']
        return DiscussIt::Listings::HnListing.new(listing)
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
    class SlashdotFetch

      #  returns big hash of all slashdot listings for a query
      def initialize(query_string)
        begin
          slashdot_raw = Fetch.get_response(api_url, query_string)
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
        return DiscussIt::Listings::SlashdotListing.new(listing)
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
    # Formats url, gets response and returns parsed json
    # ABSTRACT ONLY, called w/ RedditFetch, HnFetch, SlashdotFetc
    #----------------------------------------------------------------------
    class Fetch

      include HTTParty

      # Sets lower timeout for HTTParty
      # TEMP: test the timeout in staging/production
      default_timeout 6

      # returns ruby hash of parsed object
      def self.parse(response, type='json')
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
      def self.ensure_http(user_string)
        valid_url = user_string
        valid_url = "http://" + user_string unless user_string.match(/(http|https):\/\//)
        return valid_url
      end

      # TODO: make this an instance_method and eliminate Fetch.get_response in DiscussItApi
      #  makes http call with query_string and returns ruby hash
      def self.get_response(api_url, query_string)
        begin
          query_url = ensure_http(query_string)
          response = get(api_url + query_url, :headers => {"User-Agent" => "DiscussItAPI at github.com/discuss-it"})
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

  end

end
