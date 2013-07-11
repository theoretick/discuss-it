#
#

# [TODO] are these necessary? or does rails already have 'em
require 'net/http'
require 'json'


class DiscussItUrlError < Exception; end

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
  # initializes new Api object with target url parameter
  def initialize(target_link)
    @target_link = target_link
  end


  # [REFACTOR] Fetch responsibility
  # [TODO] change to get_json
  def get_response(site, query_domain)
    begin
      # if no trailing forward-slash, add one
      query_domain + '/' unless query_domain[-1] =~ /\//
      # if no prefixed http protocol, add one
      'http://' + query_domain unless query_domain[0..7] =~ /(http|https):\/\//

      uri = URI(site + query_domain)
      response = Net::HTTP.get_response(uri)
      return JSON.parse(response.body)
    # if http://xxx/ is invalid url content, raise error
    rescue URI::InvalidURIError => e
      raise DiscussItUrlError.new
    end
  end

  # [REFACTOR] Fetch responsibility
  # [TODO] change to get_json
  def fetch(site)
    site_response = get_response(site[:api], @target_link)

    # return site_response["data"]["children"] if site == SITES[:reddit]
    # return site_response["results"]          if site == SITES[:hn]
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
      site_response = fetch(site_links)
      top = parse_response(site_name, site_response)
      results.push(site_links[:base] + top) unless top.nil?
    end

    return results
  end

end

# d = DiscussItApi.new('http://jmoiron.net/blog/japanese-peer-peer/')
# puts d.find_all

