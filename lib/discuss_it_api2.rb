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

  # standardizes hash keys for site listings
  def standardize(raw_hash)
    standardized_hash = {}

    raw_hash.each_pair do |k,v|
      # finds key 'permalink' and changes keyname to 'location', else copies
      if k == "permalink"
        standardized_hash["location"] = v
      else
        standardized_hash[k] = v
      end
    end
    return standardized_hash
  end

  # creates Listing instance from standardized keys
  def build_listing(in_hash)
    listing = standardize(in_hash['data'])
    return Listing.new(listing)
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

  # standardizes hash keys for site listings
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
    # FIXME: up one level in the hash is weighting data for HN
    listing        = standardize(in_hash['item'])
    return Listing.new(listing)
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


# FIXME: implement site key/val in def standardize() to sort listings (i.e. site:'reddit')
class DiscussItApi

  attr_accessor :reddit_listings
  attr_accessor :hn_listings

  # initializes fetchers and calls listing builders
  def initialize(query_string)

    reddit_fetch = RedditFetch.new(query_string)
    hn_fetch     = HnFetch.new(query_string)

    @reddit_listings = reddit_fetch.build_all_listings
    @hn_listings     = hn_fetch.build_all_listings
  end

  # returns an array of all listing urls for each site
  def find_all

    base_reddit = 'http://www.reddit.com'
    base_hn     = 'http://news.ycombinator.com/item?id='
    results     = []

    unless @reddit_listings.empty?
      @reddit_listings.each do |listing|
        results << base_reddit + listing.location
      end
    end

    unless @hn_listings.empty?
      @hn_listings.each do |listing|
        results << base_hn + listing.location.to_s # hn location from id num
      end
    end

    return results
  end

  # returns an array of one listing url with the highest score for each site
  def find_top

    base_reddit = 'http://www.reddit.com'
    base_hn     = 'http://news.ycombinator.com/item?id='
    top_results     = {}

    unless @reddit_listings.empty?

      reddit_top_score = @reddit_listings.first.score
      reddit_top_location = @reddit_listings.first.location

      @reddit_listings.each do |listing|
        if (listing.score <=> reddit_top_score) == 1
          top_results[:reddit] = {
            :title => listing.title,
            :location => base_reddit + listing.location
          }
        else
          top_results[:reddit] = {
            :title => listing.title,
            :location => base_reddit + reddit_top_location
          }
        end
      end
    end

    unless @hn_listings.empty?

      hn_top_score = @hn_listings.first.score
      hn_top_location = @hn_listings.first.location.to_s

      @hn_listings.each do |listing|
        if (listing.score <=> hn_top_score) == 1
          top_results[:hn] = {
            :title => listing.title,
            :location => base_hn + listing.location
          }
        else
          top_results[:hn] = {
            :title => listing.title,
            :location => base_hn + hn_top_location
          }
        end
      end
    end

    return top_results
  end
end

