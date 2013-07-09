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

end
