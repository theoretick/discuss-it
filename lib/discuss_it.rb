#----------------------------------------------------------------------
# DiscussItApi v0.4.8
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

module DiscussIt

  #----------------------------------------------------------------------
  # - initializes site fetchers
  # - calls listing builders
  # - provides all and top accessors
  #----------------------------------------------------------------------
  class DiscussItApi
    include DiscussIt

    attr_accessor :all_listings

    # Uses query_url to check cache and verify expiration before
    # initiating a new API call
    def self.cached_request(query_url, api_version)
      # TEMP: keep caching disabled in production?
      if Rails.env.development?
        DiscussIt::DiscussItApi.new(query_url, api_version)
      else
        Rails.cache.fetch query_url, :expires_in => 1.hour do
          DiscussIt::DiscussItApi.new(query_url, api_version)
        end
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

      @all_listings    = ListingCollection.new

      @all_listings.all = reddit_fetch.listings
      @all_listings.all += hn_fetch.listings
      @all_listings.all += slashdot_fetch.listings if slashdot_fetch
    end

    # returns a ListingCollection of all returned listings.
    def find_all
      return @all_listings
    end

    # returns an Array of 1 listing per site.
    def find_top
      return @all_listings.tops
    end

    def include_slashdot?
      if VERSION_MAJOR >= 0 && VERSION_MINOR >= 3
        return true
      else
        return false
      end
    end

  end

end


