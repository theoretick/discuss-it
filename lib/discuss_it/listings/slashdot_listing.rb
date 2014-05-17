
require_relative 'base'

#----------------------------------------------------------------------
# Listing class for Slashdot with custom accessors
#----------------------------------------------------------------------
module DiscussIt

  module Listing

    class SlashdotListing < BaseListing
      # TODO: future-proof if we want to integrate num_comments globally
      def score
        return 0
      end

      # for custom ranking algorithm
      def ranking
        self['ranking'] = score + self['num_comments']
      end
    end

  end
end