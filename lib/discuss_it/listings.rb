
module DiscussIt

  #---------------------------------------------------------------------
  # collects listing objects and provides site and sort selectors
  #---------------------------------------------------------------------
  class ListingCollection

    # access ALL listings
    attr_accessor :all

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

    # Private: accessor to return only HN listings
    # Returns Array of all HnListing objects
    def hn
      all.select {|listing| listing.class == Listing::HnListing }
    end

    # Private: accessor to return only Reddit listings
    # Returns Array of all RedditListing objects
    def reddit
      all.select {|listing| listing.class == Listing::RedditListing }
    end

    # Private: accessor to return only Slashdot listings
    # Returns Array of all SlashdotListing objects
    def slashdot
      all.select {|listing| listing.class == Listing::SlashdotListing }
    end

  end


  module Listing

    #----------------------------------------------------------------------
    # creates a Listing object from listing hash w/ sort & dot-notation
    # accessors.
    #
    # ABSTRACT ONLY, instantiated w/ HnListing and RedditListing
    #----------------------------------------------------------------------
    #
    # FIXME: try moving this below Reddit/HnListings and watch it explode
    # WHAT?? does order now matter in Ruby
    class BaseListing < Hashie::Mash
      # provides sort method
      include Comparable

      def <=>(a)
        return self.ranking <=> a.ranking
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

      def comment_count
         return self["num_comments"]
      end

      def score
        return self["score"]
      end

      # for custom ranking algorithm
      def ranking
      #   return self["score"] + ( subreddit_subscribers(self["subreddit"]) + self["num_comments"] )
        return score + comment_count
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

      def comment_count
         return self["num_comments"]
      end

      def score
        return self["points"]
      end

      # for custom ranking algorithm
      def ranking
        return score + comment_count
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
      def comment_count
        return self["comment_count"]
      end

      # TODO: future-proof if we want to integrate comment_count globally
      def score
        return 0
      end

      # for custom ranking algorithm
      def ranking
        return comment_count
      end

    end

  end

end