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
    include DiscussIt

    attr_accessor :listings

    # Uses query_url to check cache and verify expiration before
    # initiating a new API call
    def self.cached_request(query_url, api_version)
      if Rails.env.development?
        puts '*'*80
        puts '=== CACHE FOR FULL API SET ==='
        puts '*'*80

        Rails.cache.fetch query_url, :expires_in => 12.hours do
          self.new(query_url, api_version)
        end
      else
        self.new(query_url, api_version)
      end
    end

    # Public: pulls all API listings into local session
    #
    # query_string - URL to be searched across sites. Call string until
    #                validity as URL is confirmed during Fetcher
    #                initializer.
    # api_version - Optional backwards compatible version number to avoid
    #               unstable new features; i.e. v2 has no slashdot
    #               results, v3 does. (default: 3)
    #
    # Examples
    #
    #   discuss_it = DiscussItApi.new('http://restorethefourth.net', 3)
    #
    # Returns nothing.
    def initialize(query_string, api_version=3)

      reddit_fetch = Fetcher::RedditFetch.new(query_string)
      hn_fetch     = Fetcher::HnFetch.new(query_string)
      slashdot_fetch = Fetcher::SlashdotFetch.new(query_string) if include_slashdot?

      @listings    = ListingCollection.new

      @listings.all = reddit_fetch.listings
      @listings.all += hn_fetch.listings
      @listings.all += slashdot_fetch.listings if slashdot_fetch
    end

    # returns a ListingCollection of all returned listings.
    def find_all
      return @listings
    end

    # returns an Array of 1 listing per site.
    def find_top
      return @listings.tops
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


