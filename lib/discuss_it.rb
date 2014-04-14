#----------------------------------------------------------------------
# DiscussItApi
#
# - interfaces with Reddit, HackerNews, and Slashdot to create sortable
# listings by URL.
#
# http://github.com/theoretick/discussit
#----------------------------------------------------------------------

require 'discuss_it/exceptions'
require 'discuss_it/listings'
require 'discuss_it/fetchers'
require 'discuss_it/filter'
require 'discuss_it/version'

require 'discuss_it/listings/reddit_listing'
require 'discuss_it/listings/hn_listing'
require 'discuss_it/listings/slashdot_listing'

module DiscussIt

  #----------------------------------------------------------------------
  # - initializes site fetchers
  # - calls listing builders
  # - provides all and top accessors
  #----------------------------------------------------------------------
  class DiscussItApi

    attr_accessor :listings

    # Equivalent to DiscussItApi.new but with caching!
    def self.cached_request(query_url, opts={})
      opts[:source]      ||= 'all'
      opts[:api_version] ||= 3

      if Rails.env.development?
        request_cache_key = "#{query_url}_#{opts[:source]}"

        Rails.cache.fetch request_cache_key, :expires_in => 12.hours do
          puts '*'*80
          puts '=== CACHING REQUEST ==='
          self.new(query_url, opts)
        end
      else
        self.new(query_url, opts)
      end
    end

    # Public: pulls API listings into local session
    #
    # query_string - URL to be searched across sites. Called string until
    #                validity as URL is confirmed during Fetcher
    #                initializer.
    # source       - Source site to retrieve listings (default: all)
    # api_version  - Optional backwards compatible version number to avoid
    #                unstable new features; i.e. v2 has no slashdot
    #                results, v3 does. (default: 3)
    #
    # Examples
    #
    #   discuss_it = DiscussItApi.new('http://restorethefourth.net')
    #
    #   discuss_it = DiscussItApi.new('http://restorethefourth.net', 'hn', 3)
    #
    # Returns nothing.
    def initialize(query_string, opts={})
      opts[:source]      ||= 'all'
      opts[:api_version] ||= 3

      @query_string = query_string

      results = case opts[:source]
                when 'reddit'
                  get_reddit.listings
                when 'hackernews', 'hn'
                  get_hn.listings
                when 'slashdot'
                  get_slashdot.listings
                when 'all'
                  get_all
                end

      @listings = ListingCollection.new(results)
    end

    # returns a ListingCollection of all returned listings.
    def find_all
      return @listings
    end

    # returns an Array of 1 listing per site.
    def find_top
      return @listings.tops
    end

    # fetch listings from all available sources.
    def get_all
      [get_reddit, get_hn, get_slashdot].reduce([]) do |all_results, src_result|
        all_results += src_result.listings
      end
    end

    def get_reddit
      Fetcher::RedditFetch.new(@query_string)
    end

    def get_hn
      Fetcher::HnFetch.new(@query_string)
    end

    def get_slashdot
      Fetcher::SlashdotFetch.new(@query_string) if include_slashdot?
    end

    def include_slashdot?
      if MAJOR >= 0 && MINOR >= 3
        return true
      else
        return false
      end
    end

  end

end


