#
# DiscussItApi class
#
# fetches url responses from Reddit and HN

require 'net/http'
require 'json'

# Exception class to catch invalid URL Errors
class DiscussItUrlError < Exception; end


class DiscussItApi

  SITES = {
    :reddit => {
      :base => 'http://www.reddit.com',
      :api => 'http://www.reddit.com/api/info.json?url=',
      # ':run' returns 'article' obj rather than parsed json obj
      :run => lambda { |response| return response["data"]["children"] }
    },
    :hn => {
      :base => 'http://news.ycombinator.com/item?id=',
      :api => 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]=',
      # ':run' returns 'article' obj rather than parsed json obj
      :run => lambda { |response| return response["results"]}
    }
  }

  SITE_KEYWORDS = {
    :reddit => {
      :data => "data",
      :score => "score",
      :location => "permalink",
    },
    :hn => {
      :data => "item",
      :score => "points",
      :location => "id",
    }
  }

  # [REFACTOR] only initialize on Article instances, which call Fetchers
  # initializes new Api object with target url parameter
  def initialize(target_link)
    @target_link = target_link
  end

  # checks or adds either 'http://' prefix and trailing '/'
  def format_url(sitename, query)
    if sitename == :hn
      query += '/' unless query.end_with?('/')
    end
    query = 'http://' + query unless query.match(/(http|https):\/\//)

    return query
  end

  # [REFACTOR] should be Fetch responsibility
  # builds URL w/ siteAPI+query, fetches URI obj, returns parsed json
  def get_json(site, user_string)
    begin
      query_domain = format_url(site, user_string)

      uri = URI(site + query_domain)
      response = Net::HTTP.get_response(uri)
      return JSON.parse(response.body)

    # if http://xxx/ is still invalid url content, raise error
    rescue URI::InvalidURIError => e
      raise DiscussItUrlError.new
    end
  end

  # [REFACTOR] should be Fetch responsibility
  def fetch(site)
    site_response = get_json(site[:api], @target_link)

    return site[:run].call(site_response)
  end

  # [REFACTOR] should be {Reddit,HN}Article responsibility
  # traverses response hash, returns highest scored submission
  def parse_response(type='all', site, listings)

    return nil if listings.empty? # nil if no results

    data     = SITE_KEYWORDS[site][:data]
    score    = SITE_KEYWORDS[site][:score]
    location = SITE_KEYWORDS[site][:location]

    top_score     = listings.first[data][score]
    top_permalink = listings.first[data][location]

    if type == 'top'
      listings.each do |posting|
        if posting[data][score] > top_score
          top_score     = posting[data][score]
          top_permalink = posting[data][location]
        end
      end
    else
      postings = []
      listings.each do |posting|
        postings << posting[data][location].to_s
      end
      return postings
    end

    return top_permalink.to_s
  end

  # fetches all urls for all sites in SITES, returns array of urls
  def find_all
    results = []

    SITES.each_pair do |site_name, site_links|
      site_response = fetch(site_links)
      all_posts = parse_response(site_name, site_response)
      if all_posts
        all_posts.each do |post|
          results.push(site_links[:base] + post) unless post.nil?
        end
      end
    end

    return results
  end

  # fetches top urls for all sites in SITES, returns array of urls
  def find_top
    results = []

    SITES.each_pair do |site_name, site_links|
      site_response = fetch(site_links)
      top = parse_response('top', site_name, site_response)
      results.push(site_links[:base] + top) unless top.nil?
    end

    return results
  end

end

# d = DiscussItApi.new('http://jmoiron.net/blog/japanese-peer-peer/')
# d = DiscussItApi.new('www.restorethefourth.net/')
# d = DiscussItApi.new('http://www.washingtonpost.com/world/national-security/for-nsa-chief-terrorist-threat-drives-passion-to-collect-it-all/2013/07/14/3d26ef80-ea49-11e2-a301-ea5a8116d211_story.html')
# puts d.find_top
# puts
# puts d.find_all
