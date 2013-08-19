
module DiscussIt

  #---------------------------------------------------------------------
  # collects listing objects and provides site and sort selectors
  #
  # tops() => sorts listings per site and returns 1 per site
  #   EXAMPLE_TOPS_RESULTS = {
  #         hn: <#HnListingx392032>
  #     reddit: <#RedditListingx0322335>
  #   slashdot: <#SlashdotListingx959584>
  #   }
  #---------------------------------------------------------------------
  class ListingCollection

    # access ALL listings
    attr_accessor :all

    # returns highest scoring single result per site
    def tops
      results = []

      results << hn.sort.last unless hn.empty?
      results << reddit.sort.last unless reddit.empty?
      results << slashdot.sort.last unless slashdot.empty?

      # return results sorted by highest score first
      return results.sort.reverse
    end

    # returns array of all HnListing objects
    def hn
      all.select {|listing| listing.class == Listing::HnListing }
    end

    # returns array of all RedditListing objects
    def reddit
      all.select {|listing| listing.class == Listing::RedditListing }
    end

    # returns array of all SlashdotListing objects
    def slashdot
      all.select {|listing| listing.class == Listing::SlashdotListing }
    end

  end


  # TODO: prob shouldn't be plural but creates name conflict w/
  # abstract object. how to rectify?
  module Listing

    #----------------------------------------------------------------------
    # creates a Listing object from listing hash w/ sort & dot-notation
    # accessors
    #
    # ABSTRACT ONLY, instantiated w/ HnListing and RedditListing
    #----------------------------------------------------------------------
    #
    # TODO: try moving this below Reddit/HnListings and watch it explode
    # WHAT?? does order now matter in Ruby
    #
    class BaseListing < Hashie::Mash
      # provides sort method
      include Comparable

      def <=>(a)
        return self.score <=> a.score
      end

    end

    #----------------------------------------------------------------------
    # Listing class for Reddit with custom accessors
    #----------------------------------------------------------------------
    class RedditListing < BaseListing

      def site
        return 'Reddit'
      end

      def base_url
        return 'http://www.reddit.com'
      end

      def location
        return base_url + self["permalink"]
      end

      def score
        return self["score"] + self["num_comments"]
      end

    end


    #----------------------------------------------------------------------
    # Listing class for HN with custom accessors
    #----------------------------------------------------------------------
    class HnListing < BaseListing

      def site
        return 'HackerNews'
      end

      def base_url
        return 'http://news.ycombinator.com/item?id='
      end

      def location
        return base_url + self["id"].to_s
      end

      def score
        return self["points"] + self["num_comments"]
      end

    end


    #----------------------------------------------------------------------
    # Listing class for Slashdot with custom accessors
    #----------------------------------------------------------------------
    class SlashdotListing < BaseListing

      def site
        return 'Slashdot'
      end

      def location
        return self["permalink"]
      end

      # TODO: future-proof if we want to integrate comment_count globally
      def score
        return self["comment_count"]
      end

    end

  end

end