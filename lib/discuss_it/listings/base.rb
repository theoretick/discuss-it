
require 'hashie'

module DiscussIt
  module Listing

    # The 2 required interfaces for a listing MUST be defined on inheritors
    module BaseInstanceMethods
      def score
        error_msg = "#{self.class} must implement #{__method__}"
        raise StandardError, error_msg
      end

      def ranking
        error_msg = "#{self.class} must implement #{__method__}"
        raise StandardError, error_msg
      end
    end

    #----------------------------------------------------------------------
    # creates a Listing object from hash w/ sortability & dot-notation
    # accessors.
    #
    # ABSTRACT - init w/ HnListing, SlashdotListing, and RedditListing
    #----------------------------------------------------------------------
    class BaseListing < Hashie::Mash
      # provide sortable
      include Comparable
      include BaseInstanceMethods

      def <=>(a)
        return self.ranking <=> a.ranking
      end
    end
  end
end
