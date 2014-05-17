
require 'hashie'

module DiscussIt
  module Listing
    #----------------------------------------------------------------------
    # creates a Listing object from hash w/ sortability & dot-notation
    # accessors.
    #
    # ABSTRACT - init w/ HnListing, SlashdotListing, and RedditListing
    #----------------------------------------------------------------------
    class BaseListing < Hashie::Mash
      # provide sortable
      include Comparable

      def <=>(a)
        return self.ranking <=> a.ranking
      end
    end
  end
end
