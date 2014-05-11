require 'hashie'

module DiscussIt

  #---------------------------------------------------------------------
  # collects listing objects and provides site and sort selectors
  #---------------------------------------------------------------------
  class ListingCollection

    # access ALL listings
    attr_accessor :all

    def initialize(listings=[])
      @all = listings
    end

    # Public: accessor to return top Listing instances in collection.
    # Top results returns a maximum of 1 result per site on which query
    # was found.
    #
    # Examples
    #
    #   top_results = @listing_collection.tops
    #   # => top_results.length == 3
    #
    # Returns Array of 1-listing per site.
    def tops
      results = []

      results << hn.sort.last unless hn.empty?
      results << reddit.sort.last unless reddit.empty?
      results << slashdot.sort.last unless slashdot.empty?

      # return results sorted by highest score first
      return results.sort.reverse
    end

    # Returns Array of only HnListing objects
    def hn
      all.select {|listing| listing.class == Listing::HnListing }
    end

    # Returns Array of only RedditListing objects
    def reddit
      all.select {|listing| listing.class == Listing::RedditListing }
    end

    # Returns Array of only SlashdotListing objects
    def slashdot
      all.select {|listing| listing.class == Listing::SlashdotListing }
    end

  end


  module Listing

    #----------------------------------------------------------------------
    # creates a Listing object from hash w/ sortability & dot-notation
    # accessors.
    #
    # ABSTRACT - init w/ HnListing, SlashdotListing, and RedditListing
    #----------------------------------------------------------------------
    class BaseListing < Hashie::Mash
      # provides sort method
      include Comparable

      def <=>(a)
        return self.ranking <=> a.ranking
      end
    end

  end
end
