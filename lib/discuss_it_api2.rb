require 'json'
require 'httparty'
require 'pry'

#Formats url, gets response and returns parsed json
class Fetch

  #  adds http prefix if not found
  def self.http_add(url)
    valid_url = url
    valid_url = "http://" + url unless url.match(/(http|https):\/\//)
    return valid_url
  end

  # returns ruby hash of parsed json object
  def self.parse_json(json)
    return JSON.parse(json)
  end

  #  makes http call with query and returns ruby hash
  def self.get_response(query_string, api_url)
    valid_uri = self.http_add(query_string)
    response = HTTParty.get(api_url + valid_uri)
    return self.parse_json(response.body)
  end

end

# traverses hash, standardizes variables and misc and stuff
#######################################################################
# FIXME: need to figure out how to call get_response without calling Fetch class
# super. does not work - we need inheritance with class methods
class RedditFetch # < Fetch

  API_URL = 'http://www.reddit.com/api/info.json?url='

  #  returns big has of all reddit listings for a query
  def initialize(query_url)

    # formatted_url = api_url(query_url)

    reddit_raw_a = Fetch.get_response(query_url, API_URL)
    if query_url.end_with?('/')
      reddit_raw_b = Fetch.get_response(query_url, API_URL)
    else
      reddit_raw_b = Fetch.get_response(query_url + '/', API_URL)
    end
    @raw_master = pull_out(reddit_raw_a) + pull_out(reddit_raw_b)
  end

  # returns an array of raw hash listings
  def pull_out(parent_hash)
    return parent_hash["data"]["children"]
  end

  # standardizes hash keys for site response listings
  def standardize(raw_hash)
    standardized_hash = {}

    raw_hash.each_pair do |k,v|
      if k == "permalink"
        standardized_hash["location"] = v
      else
        standardized_hash[k] = v
      end
    end
    return standardized_hash
  end

  # creates listing with standardized keys
  def build_listing(in_hash)
    listing = standardize(in_hash['data'])
    reddit_listing = Listing.new(listing)
    return reddit_listing
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


class HnFetch # FIXME: < Fetch

  API_URL = 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]='

  #  returns a hash of HN listings for a query
  def initialize(query_url)

    # formatted_url = api_url(query_url)

    if query_url.end_with?('/')
      hn_raw = Fetch.get_response(query_url, API_URL)
    else
      hn_raw = Fetch.get_response(query_url + '/', API_URL)
    end
    @raw_master = pull_out(hn_raw)
  end

  # returns an array of raw hash listings
  def pull_out(parent_hash)
    return parent_hash["results"]
  end

  # standardizes hash keys for site response listings
  def standardize(raw_hash)
    standardized_hash = {}

    raw_hash.each_pair do |k,v|
      if k == "id"
        standardized_hash["location"] = v
      elsif k == "points"
        standardized_hash["score"] = v
      else
        standardized_hash[k] = v
      end
    end
    return standardized_hash
  end

  # creates listing with standardized keys
  def build_listing(in_hash)
    listing = standardize(in_hash['item']) # FIXME: up one level in the hash is weighting data for HN
    reddit_listing = Listing.new(listing)
    return reddit_listing
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
class Listing < Hashie::Mash; end


# FIXME: implement site key value in def standardize to sort listings
class DiscussItApi
  attr_accessor :reddit_listings
  # initializes fetchers and calls listing builders
  def initialize(query_string)
    erddit = RedditFetch.new(query_string)
    @reddit_listings = erddit.build_all_listings

    ahcker = HnFetch.new(query_string)
    @hacker_listings = ahcker.build_all_listings
  end

  # returns an array of all listing urls for each site
  def find_all

    base_reddit = 'http://www.reddit.com'
    base_hn = 'http://news.ycombinator.com/item?id='
    results = []

    @reddit_listings.each do |listing|
      results << base_reddit + listing.location.to_s
    end

    @hacker_listings.each do |listing|
      results << base_hn + listing.location.to_s
    end

    return results
  end

  # FIXME: KILL ME returns an array of one listing url with the highest score for each site
  def find_top

    base_reddit = 'http://www.reddit.com'
    base_hn = 'http://news.ycombinator.com/item?id='
    results = []

    reddit_top_url = @reddit_listings.first.location
    reddit_top_score = @reddit_listings.first.score
    hn_top_url = @hacker_listings.first.location
    hn_top_score = @hacker_listings.first.score

    @reddit_listings.each do |listing|
      if listing.score > reddit_top_score
        results << base_reddit + listing.location
      end
    end

    @hacker_listings.each do |listing|
      if listing.score > hn_top_score
        results << base_hn + listing.location
      end
    end

    return [reddit_top_url] + [hn_top_url]

  end
end
