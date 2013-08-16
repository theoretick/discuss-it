#----------------------------------------------------------------------
# FIXME: change this to 0.4 (here, discuss_it/version, and changelog)
# DiscussItApi v4.0.0
#
# - interfaces with Reddit, HackerNews, and Slashdot to create sortable
# listings by URL.
#
# http://github.com/theoretick/discussit
#----------------------------------------------------------------------

require 'discuss_it/exceptions'
require 'discuss_it/listings'
require 'discuss_it/fetchers'
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

    # Defaults to newest API, beta version (v3 with slashdot)
    def initialize(query_string, api_version=3)

      # FIXME: the VERSION_MINOR is super brittle, make better
      api_version ||= DiscussIt::VERSION_MINOR

      reddit_fetch = Fetcher::RedditFetch.new(query_string)
      hn_fetch     = Fetcher::HnFetch.new(query_string)
      slashdot_fetch = Fetcher::SlashdotFetch.new(query_string) if api_version >= 3
      @all_listings    = ListingCollection.new

      @all_listings.all = reddit_fetch.listings
      @all_listings.all += hn_fetch.listings
      @all_listings.all += slashdot_fetch.listings if slashdot_fetch
    end

    # returns a ListingCollection of all listing urls for each site
    # TODO: this should be standardized to a hash for consistency
    def find_all
      return @all_listings
    end

    # returns a HASH of 1-per-site listings w/ highest score for each site
    def find_top
      return @all_listings.tops
    end

  end

end


