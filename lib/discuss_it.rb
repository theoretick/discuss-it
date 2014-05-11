#----------------------------------------------------------------------
# DiscussItApi
#
# - interfaces with Reddit, HackerNews, and Slashdot to create sortable
# listings by URL.
#
# http://github.com/theoretick/discussit
#----------------------------------------------------------------------

require_relative 'discuss_it/exceptions'
require_relative 'discuss_it/listings'
require_relative 'discuss_it/fetchers'
require_relative 'discuss_it/filter'
require_relative 'discuss_it/caching'
require_relative 'discuss_it/version'

require_relative 'discuss_it/listings/reddit_listing'
require_relative 'discuss_it/listings/hn_listing'
require_relative 'discuss_it/listings/slashdot_listing'

module DiscussIt

  #----------------------------------------------------------------------
  # - initializes site fetchers
  # - calls listing builders
  # - provides all and top accessors
  #----------------------------------------------------------------------
  class DiscussItApi

    attr_accessor :listings
    attr_reader   :errors

    # Public: pulls API listings into local session
    #
    # query_string - URL to be searched across sites. Called string until
    #                validity as URL is confirmed during Fetcher
    #                initializer.
    # source       - Source site to retrieve listings (default: all)
    # api_version  - Optional backwards compatible version number to avoid
    #                unstable new features; i.e. v2 has no slashdot
    #                results, v3 does. (default: 3)
    #
    # Examples
    #
    #   discuss_it = DiscussItApi.new('http://restorethefourth.net')
    #
    #   discuss_it = DiscussItApi.new('http://restorethefourth.net', source: 'hn', api_version: 3)
    #
    # Returns nothing.
    def initialize(query_string, opts={})
      opts[:source]      ||= ['all']
      opts[:api_version] ||= 3

      @query_string = query_string
      @errors = []
      results = []

      results = opts[:source].reduce([]) do |arr, src|
                  arr +=  case src
                          when 'reddit'
                            get_reddit.listings
                          when 'hackernews', 'hn'
                            get_hn.listings
                          when 'slashdot'
                            get_slashdot.listings
                          when 'all'
                            get_all
                          end
                end

      @listings = ListingCollection.new(results)
    end

    # returns a ListingCollection of all returned listings.
    def find_all
      return @listings
    end

    # returns an Array of 1 listing per site.
    def find_top
      return @listings.tops
    end

    private

    # fetch listings from all available sources.
    def get_all
      [get_reddit, get_hn, get_slashdot].reduce([]) do |all_results, src_result|
        all_results += src_result.listings
      end
    end

    def get_reddit
      fetcher = Fetcher::RedditFetch.new(@query_string)
      @errors += fetcher.errors
      return fetcher
    end

    def get_hn
      fetcher = Fetcher::HnFetch.new(@query_string)
      @errors += fetcher.errors
      return fetcher
    end

    def get_slashdot
      if include_slashdot?
        fetcher = Fetcher::SlashdotFetch.new(@query_string)
      @errors += fetcher.errors
        return fetcher
      end
    end

    def include_slashdot?
      if MAJOR >= 0 && MINOR >= 3
        return true
      else
        return false
      end
    end

  end

end


