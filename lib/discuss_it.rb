#----------------------------------------------------------------------
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

#----------------------------------------------------------------------
# - initializes site fetchers
# - calls listing builders
# - provides all and top accessors
#----------------------------------------------------------------------
# TODO: consider renaming, this isn't an API just yet
class DiscussItApi

  attr_accessor :all_listings

  # FIXME: api version 2 by default
  # api_version 3 w/ slashdot by default
  def initialize(query_string, api_version)

    reddit_fetch = DiscussIt::Fetcher::RedditFetch.new(query_string)
    hn_fetch     = DiscussIt::Fetcher::HnFetch.new(query_string)
    slashdot_fetch = DiscussIt::Fetcher::SlashdotFetch.new(query_string) if api_version == '3'
    @all_listings    = DiscussIt::ListingCollection.new

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
