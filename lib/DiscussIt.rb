#
#
#
# [TODO] add catch-all behavior (http prefix, trailing slash, etc)

require 'net/http'
require 'json'

class DiscussIt

  SITES = {
    :reddit => {
      :base => 'http://www.reddit.com',
      :api => 'http://www.reddit.com/api/info.json?url='
    },
    :hn => {
      :base => 'http://news.ycombinator.com/item?id=',
      :api => 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]='
    }
  }

  def initialize(target_link)
    @target_link = target_link
  end

  def get_response(site, query_domain)
    uri = URI(site + query_domain)
    response = Net::HTTP.get_response(uri)
    return JSON.parse(response.body)
  end

  def fetch(site)
    # fetches response, then traverses ruby hash
    site_response = get_response(site[:api], @target_link)

    return site_response["data"]["children"] if site == SITES[:reddit]
    return site_response["results"]          if site == SITES[:hn]
  end


  def parse_response(site, listings)

    return nil if listings.empty? # nil if no results

    if site == :reddit      # [TODO] refactor if/else in less-hardcoded way
        data     = "data"
        score    = "score"
        location = "permalink"
    elsif site == :hn
        data     = "item"
        score    = "points"
        location = "id"
    end

    top_score     = listings.first[data][score]
    top_permalink = listings.first[data][location]

    listings.each do |posting|
      if posting[data][score] > top_score
        top_score     = posting[data][score]
        top_permalink = posting[data][location]
      end
    end

    return top_permalink.to_s
  end

  # def parse_reddit(listings)
  #   # iterates through results, returns permalink of post w/ highest raw score

  #   return nil if listings.empty? # nil if no results

  #   top_score     = listings.first["data"]["score"]
  #   top_permalink = listings.first["data"]["permalink"]

  #   listings.each do |posting|
  #     if posting["data"]["score"] > top_score
  #       top_score     = posting["data"]["score"]
  #       top_permalink = posting["data"]["permalink"]
  #     end
  #   end
  #   return top_permalink.to_s
  # end

  # def parse_hn(listings)
  #   # iterates through results, returns permalink of post w/ highest raw score

  #   return nil if listings.empty? # nil if no results

  #   top_score     = listings.first["item"]["points"]
  #   top_permalink = listings.first["item"]["id"]

  #   listings.each do |posting|
  #     if posting["item"]["points"] > top_score
  #       top_score     = posting["item"]["points"]
  #       top_permalink = posting["item"]["id"]
  #     end
  #   end
  #   return top_permalink.to_s
  # end

  def find_all
    # fetches url for all sites in SITES, returns array of urls
    results = []

    SITES.each_pair do |site_name, site_links|
      site_response = fetch(site_links)
      top = parse_response(site_name, site_response)
      results.push(site_links[:base] + top) unless top.nil?
    end

    # response = fetch(SITES[:reddit])
    # top = parse_reddit(response)
    # results.push(REDDIT_BASE + top) unless top.nil?

    # response = fetch(SITES[:hn])
    # top = parse_hn(response)
    # results.push(HN_BASE + top) unless top.nil?

    return results
  end

end


# d = DiscussIt.new(nil.to_s)
# links = d.find_all  # returns top discussion urls
# puts links


###################################################################




###################################################################


#
#
#
# [TODO] add catch-all behavior (http prefix, trailing slash, etc)

require 'net/http'
require 'json'

class DiscussItApi

  SITES = {
    :reddit => {
      :base => 'http://www.reddit.com',
      :api => 'http://www.reddit.com/api/info.json?url=',
      # ':run' returns 'article' obj rather than parsed json obj
      :run => lambda { |response| return  response["data"]["children"] }
    },
    :hn => {
      :base => 'http://news.ycombinator.com/item?id=',
      :api => 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]=',
      # ':run' returns 'article' obj rather than parsed json obj
      :run => lambda { |response| return response["results"]}
    }
  }

  # [REFACTOR] only initialize articles, which call Fetchers
  def initialize(target_link)
    @target_link = target_link
  end

  # [REFACTOR] Fetch responsibility
  # [TODO] change to get_json
  def get_response(site, query_domain)
    uri = URI(site + query_domain)
    response = Net::HTTP.get_response(uri)
    return JSON.parse(response.body)
  end

  # [REFACTOR] {Reddit,HN}Fetch responsibility
  # fetches response, then traverses ruby hash
  def fetch(site)
    site_response = get_response(site[:api], @target_link)

    return site[:run].call(site_response)
  end

  # [REFACTOR] {Reddit,HN}Article responsibility
  # traverses response hash, returns highest scored submission
  def parse_response(site, listings)

    return nil if listings.empty? # nil if no results

    if site == :reddit      # [TODO] refactor if/else in less-hardcoded way
        data     = "data"
        score    = "score"
        location = "permalink"
    elsif site == :hn
        data     = "item"
        score    = "points"
        location = "id"
    end

    top_score     = listings.first[data][score]
    top_permalink = listings.first[data][location]

    listings.each do |posting|
      if posting[data][score] > top_score
        top_score     = posting[data][score]
        top_permalink = posting[data][location]
      end
    end

    return top_permalink.to_s
  end

  def find_all
    # fetches url for all sites in SITES, returns array of urls
    results = []

    SITES.each_pair do |site_name, site_links|
      # puts "#{site_name} $$$$site_name"
      # puts "#{site_links} $$$$site_links"
      site_response = fetch(site_links)
      top = parse_response(site_name, site_response)
      results.push(site_links[:base] + top) unless top.nil?
    end

    return results
  end

end

@e = DiscussItApi.new('http://jmoiron.net/blog/japanese-peer-peer/')
# puts d.find_all


