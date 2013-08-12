
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

    def tops
      results = {}

      results[:hn] = hn.sort.last unless hn.empty?
      results[:reddit] = reddit.sort.last unless reddit.empty?
      results[:slashdot] = slashdot.sort.last unless slashdot.empty?

      return results
    end

    # returns array of all HnListing objects
    def hn
      all.select {|listing| listing.class == Listings::HnListing }
    end

    # returns array of all RedditListing objects
    def reddit
      all.select {|listing| listing.class == Listings::RedditListing }
    end

    # returns array of all SlashdotListing objects
    def slashdot
      all.select {|listing| listing.class == Listings::SlashdotListing }
    end

  end


  # TODO: prob shouldn't be plural but creates name conflict w/
  # abstract object. how to rectify?
  module Listings

    #----------------------------------------------------------------------
    # creates a Listing object from listing hash w/ sort & dot-notation
    # accessors
    #
    # ABSTRACT ONLY, instantiated w/ HnListing and RedditListing
    #----------------------------------------------------------------------
    #
    # TODO: !!!try moving this below Reddit/HnListings and watch it explode
    # WHAT?? does order now matter in Ruby
    #
    class Listing < Hashie::Mash
      # provides sort method
      include Comparable

      def <=>(a)
        return self.score <=> a.score
      end

    end

    #----------------------------------------------------------------------
    # Listing class for Reddit with custom accessors
    #----------------------------------------------------------------------
    class RedditListing < Listing

      def base_url
        return 'http://www.reddit.com'
      end

      def location
        return base_url + self["permalink"]
      end

      def score
        return self["score"]
      end

    end


    #----------------------------------------------------------------------
    # Listing class for HN with custom accessors
    #----------------------------------------------------------------------
    class HnListing < Listing

      def base_url
        return 'http://news.ycombinator.com/item?id='
      end

      def location
        return base_url + self["id"].to_s
      end

      def score
        return self["points"]
      end

    end


    #----------------------------------------------------------------------
    # Listing class for Slashdot with custom accessors
    #----------------------------------------------------------------------
    class SlashdotListing < Listing

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