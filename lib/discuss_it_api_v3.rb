#----------------------------------------------------------------------
# DiscussItApi v3.5
#
# - interfaces with Reddit, HackerNews (and Slashdot) to create sortable listings
# by URL.
#
# http://github.com/theoretick/discussit
#----------------------------------------------------------------------
require 'json'
require 'httparty'

#----------------------------------------------------------------------
# Exception class to catch invalid URL Errors
#----------------------------------------------------------------------
class DiscussItUrlError < Exception; end


#----------------------------------------------------------------------
# Formats url, gets response and returns parsed json
# ABSTRACT ONLY, called w/ RedditFetch and HnFetch
#----------------------------------------------------------------------
class Fetch

  # returns ruby hash of parsed json object
  # FIXME: currently only JSON, possible XML for future
  def self.parse(response)
    return JSON.parse(response)
  end

  # ensures url passed to API has http prefix
  def self.ensure_http(user_string)
    valid_url = user_string
    valid_url = "http://" + user_string unless user_string.match(/(http|https):\/\//)
    return valid_url
  end

  #  makes http call with query_string and returns ruby hash
  def self.get_response(api_url, query_string)
    begin
      query_url = ensure_http(query_string)
      response = HTTParty.get(api_url + query_url)
      return self.parse(response.body)

    # if http://xxx is still invalid url content, raise error
    # ```http://%% #=> raise DiscussItUrlError```
    rescue URI::InvalidURIError => e
      raise DiscussItUrlError.new
    end
  end

end


#----------------------------------------------------------------------
# fetches API response from Reddit
# provides site-specific details: key-names and urls
#----------------------------------------------------------------------
class RedditFetch < Fetch

  #  returns big hash of all reddit listings for a query
  def initialize(query_string)

    # ALWAYS remove trailing slash before get_response calls
    if query_string.end_with?('/')
      query_url = query_string.chop
    else
      query_url = query_string
    end

    reddit_raw_a = Fetch.get_response(api_url, query_url)
    reddit_raw_b = Fetch.get_response(api_url, query_url + '/')

    # return master hash of both combined API calls
    @raw_master = pull_out(reddit_raw_a) + pull_out(reddit_raw_b)
  end

  def api_url
    return 'http://www.reddit.com/api/info.json?url='
  end

  # returns relevant subarray of raw hash listings
  def pull_out(parent_hash)
    return parent_hash["data"]["children"]
  end

  # gets called in DiscussItApi to build reddit listings
  # if not already built
  def listings
    return @listings ||= build_all_listings
  end

  def build_listing(parent_hash)
    listing = parent_hash['data']
    return RedditListing.new(listing)
  end

  # creates array of listing objects for all responses
  def build_all_listings
    all_listings = []
    # FIXME: should this be switched to a map() call?
    @raw_master.each do |listing|
      all_listings << build_listing(listing)
    end
    return all_listings
  end
end


#----------------------------------------------------------------------
# fetches API response from HackerNews
# provides site-specific details: key-names and urls
#----------------------------------------------------------------------
class HnFetch < Fetch

  #  returns a hash of HN listings for a query
  def initialize(query_string)

    # ALWAYS remove trailing slash before get_response calls
    if query_string.end_with?('/')
      query_url = query_string.chop
    else
      query_url = query_string
    end

    hn_raw = Fetch.get_response(api_url, query_url + '/')
    @raw_master = pull_out(hn_raw)
  end

  def api_url
    return 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]='
  end

  # returns relevant subarray of raw hash listings
  def pull_out(parent_hash)
    return parent_hash["results"]
  end

  # gets called in DiscussItApi to build HN listings
  # if not already built
  def listings
    return @listings ||= build_all_listings
  end

  def build_listing(parent_hash)
    # FIXME: up one level in the hash is weighting data for HN
    listing = parent_hash['item']
    return HnListing.new(listing)
  end

  # creates array of listing objects for all responses
  def build_all_listings
    all_listings = []
    # FIXME: should this be switched to a map() call?
    @raw_master.each do |listing|
      all_listings << build_listing(listing)
    end
    return all_listings
  end
end


#----------------------------------------------------------------------
# fetches persistentlistings locally from (Slashdot) Listing controllers
# provides site-specific details: key-names and urls
#----------------------------------------------------------------------
class SlashdotFetch < Fetch

  #  returns big hash of all slashdot listings for a query
  def initialize(query_string)
    # @slashdot_listings = Fetch.get_response(api_url, query_string)
    @slashdot_listings =  {
         "hits" => 2,
      "results" => []
    }
    @raw_master = pull_out(@slashdot_listings)
  end

  def api_url
    # FIXME: this work?
    return 'listings/find_by_url/'
  end

  # returns relevant subarray of raw hash listings
  def pull_out(parent_hash)
    return parent_hash["results"]
  end

  # gets called in DiscussItApi to build Slashdot listings
  # if not already built
  def listings
    return @listings ||= build_all_listings
  end

  def build_listing(parent_hash)
    # FIXME: up one level in the hash is weighting data for HN
    listing = parent_hash
    return SlashdotListing.new(listing)
  end

  # creates array of listing objects for all responses
  def build_all_listings
    all_listings = []
    # FIXME: should this be switched to a map() call?
    @raw_master.each do |listing|
      all_listings << build_listing(listing)
    end
    return all_listings
  end

end


#----------------------------------------------------------------------
# takes listing hash and creates a listing obj
# with sort & dot-notation accessors
# ABSTRACT ONLY, instantiated w/ HnListing and RedditListing
#----------------------------------------------------------------------
class Listing < Hashie::Mash
  # provides sort method
  include Comparable

  def <=>(a)
    return self.score <=> a.score
  end

end


#----------------------------------------------------------------------
# Listing class for HN with custom accessors
#----------------------------------------------------------------------
class HnListing < Listing

  def base_url
    return 'http://news.ycombinator.com/item?id='
  end

  def location
    return base_url + self["id"].to_s
  end

  def score
    return self["points"]
  end

end


#----------------------------------------------------------------------
# Listing class for HN with custom accessors
#----------------------------------------------------------------------
class RedditListing < Listing

  def base_url
    return 'http://www.reddit.com'
  end

  def location
    return base_url + self["permalink"]
  end

  def score
    return self["score"]
  end

end


#----------------------------------------------------------------------
# Listing class for Slashdot with custom accessors
# FIXME: should be moved to raketask?
#----------------------------------------------------------------------
class SlashdotListing < Listing
end

#----------------------------------------------------------------------
# collects listing objects and provides site and sort selectors
  #  - sorts listings per site and returns 1 per site
  #  - with top score.
  #  - key is sitename
#
  # example_results = {
  #       hn: {
  #           ...
  #           points: 3,
  #              id: 3934943,
  #           ...
  #          }
  #   reddit: {
  #           ...
  #           score: 7,
  #       permalink: "/r/foo/fake_url_permalink",
  #           ...
  #          }
  # }
#----------------------------------------------------------------------
class ListingCollection

  # access ALL listings
  attr_accessor :all

  def initialize
  end

  def tops
    results = {}

    results[:hn] = hn.sort.first unless hn.empty?
    results[:reddit] = reddit.sort.first unless reddit.empty?
    results[:slashdot] = slashdot.sort.first unless slashdot.empty?

    return results
  end

  # returns array of all HnListing objects
  def hn
    all.select {|listing| listing.class == HnListing }
  end

  # returns array of all RedditListing objects
  def reddit
    all.select {|listing| listing.class == RedditListing }
  end

  # returns array of all SlashdotListing objects
  def slashdot
    all.select {|listing| listing.class == SlashdotListing }
  end

end


#----------------------------------------------------------------------
# public interface
  # - initializes site fetchers
  # - calls listing builders
  # - finds all listings
  # - finds top listings (1 per site)
#----------------------------------------------------------------------
class DiscussItApi

  attr_accessor :all_listings

  def initialize(query_string)

    reddit_fetch = RedditFetch.new(query_string)
    hn_fetch     = HnFetch.new(query_string)
    slashdot_fetch = SlashdotFetch.new(query_string)
    @all_listings    = ListingCollection.new

    @all_listings.all = reddit_fetch.listings
    # shovel creates a nested array item, use += instead
    @all_listings.all += hn_fetch.listings
    @all_listings.all += slashdot_fetch.listings
  end

  # returns a ListingCollection of all listing urls for each site
  # FIXME: this should probably be standardized to a hash for consistency
  def find_all
    return @all_listings
  end

  # returns a HASH of listings w/ highest score for each site
  def find_top
    return @all_listings.tops
  end
end

