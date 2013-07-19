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
  def self.get_response(query_string)
    valid_uri = self.http_add(query_string)
    response = HTTParty.get(valid_uri)
    return self.parse_json(response.body)
  end

end

# traverses hash, standardizes variables and misc and stuff
class RedditFetch < Fetch

  #  returns big has of all reddit listings for a query
  def initialize(query_url)

    formatted_url = api_url(query_url)

    reddit_raw_a = Fetch.get_response(formatted_url)
    if formatted_url.end_with?('/')
      reddit_raw_b = Fetch.get_response(formatted_url)
    else
      reddit_raw_b = Fetch.get_response(formatted_url + '/')
    end
    @raw_master = pull_out(reddit_raw_a) + pull_out(reddit_raw_b)
  end

  def api_url(url)
    return 'http://www.reddit.com/api/info.json?url='+ url
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
    listing = standardize(in_hash)
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


class HnFetch < Fetch

end

# takes listing hash and creates a listing array of objects
class Listing

  # def initialize(listing_hash)

  # end

end

class DiscussItApi

  # initializes fetchers and calls listing builders
  def initialize(query_string)
    erddit = RedditFetch.new(query_string)
    @reddit_listings = erddit.build_all_listings

    ahcker = HnFetch.new(query_string)
    @hacker_listings = ahcker.build_all_listings
  end

  def find_all

  end

  def find_top

  end

# calls RedditFetch
# calls HnFetch
# gets dem objects (arrays?)
# finds all
# finds top
end
