require 'json'
require 'httparty'

# Exception class to catch invalid URL Errors
class DiscussItUrlError < Exception; end

#Formats url, gets response and returns parsed json
class Fetch

  # adds http prefix if not found
  def self.http_add(url)
    valid_url = url
    valid_url = "http://" + url unless url.match(/(http|https):\/\//)
    return valid_url
  end

  # returns ruby hash of parsed json object
  def self.parse(response)
    return JSON.parse(response)
  end

  #  makes http call with query_string and returns ruby hash
  def self.get_response(api_url, query_string)
    begin
      valid_uri = self.http_add(query_string)
      response = HTTParty.get(api_url + valid_uri)
      return self.parse(response.body)

    # if http://xxx/ is still invalid url content, raise error
    rescue URI::InvalidURIError => e
      raise DiscussItUrlError.new
    end
  end

end

# traverses hash, standardizes variables and misc and stuff
#######################################################################
class RedditFetch < Fetch

  API_URL = 'http://www.reddit.com/api/info.json?url='

  #  returns big has of all reddit listings for a query
  def initialize(query_url)

    reddit_raw_a = Fetch.get_response(API_URL, query_url)
    if query_url.end_with?('/')
      # FIXME: needs to trim trailing slash, else identical call as raw_a
      reddit_raw_b = Fetch.get_response(API_URL, query_url)
    else
      reddit_raw_b = Fetch.get_response(API_URL, query_url + '/')
    end
    # return master hash of both combined API calls
    @raw_master = pull_out(reddit_raw_a) + pull_out(reddit_raw_b)
  end

  # returns relevant subarray of raw hash listings
  def pull_out(parent_hash)
    return parent_hash["data"]["children"]
  end

  # gets called in DiscussItApi to build reddit listings
  #   if not already built
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


class HnFetch < Fetch

  API_URL = 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]='

  #  returns a hash of HN listings for a query
  def initialize(query_url)

    if query_url.end_with?('/')
      hn_raw = Fetch.get_response(API_URL, query_url)
    else
      hn_raw = Fetch.get_response(API_URL, query_url + '/')
    end
    @raw_master = pull_out(hn_raw)
  end

  # returns relevant subarray of raw hash listings
  def pull_out(parent_hash)
    return parent_hash["results"]
  end

  # gets called in DiscussItApi to build reddit listings
  #   if not already built
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
    @raw_master.each do |listing|
      all_listings << build_listing(listing)
    end
    return all_listings
  end
end

# takes listing hash and creates a listing array of objects
# FIXME: consider using just Hashie::Extension::MethodReader or MethodQuery
class Listing < Hashie::Mash
  # provides sort method
  include Comparable

  def <=>(a)
    return self.score <=> a.score
  end

end


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

# FIXME: implement site key/val in def standardize() to sort listings (i.e. site:'reddit')
class DiscussItApi

  attr_accessor :all_listings

  # initializes fetchers and calls listing builders
  def initialize(query_string)

    reddit_fetch = RedditFetch.new(query_string)
    hn_fetch     = HnFetch.new(query_string)
    @all_listings    = ListingCollection.new

    @all_listings.all = reddit_fetch.listings
    # shovel creates a nested array item
    @all_listings.all += hn_fetch.listings
  end

  # returns a ListingCollection of all listing urls for each site
  def find_all
    return @all_listings
  end

  # returns a HASH of listings w/ highest score for each site
  def find_top
    return @all_listings.tops
  end
end

class ListingCollection

  # access ALL listings
  attr_accessor :all

  def initialize
  end

  # sorts listings per site and returns the one with the top score
  def tops
    results = {}

    results[:hn] = hn.sort.first unless hn.empty?
    results[:reddit] = reddit.sort.first unless reddit.empty?

    return results
  end

  # returns all HN listing objects
  def hn
    all.select {|listing| listing.class == HnListing }
  end

  # returns all reddit listing objects
  def reddit
    all.select {|listing| listing.class == RedditListing }
  end

  # returns all listings for Reddit and HN
  def locations
    return all.map {|listing| listing.location}
  end

end



