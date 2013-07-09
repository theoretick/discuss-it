#
#

require 'net/http'
require 'json'

class DiscussItApi

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

