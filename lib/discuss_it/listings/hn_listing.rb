
require_relative 'base'

#----------------------------------------------------------------------
# Listing class for HN with custom accessors
#----------------------------------------------------------------------
module DiscussIt

  module Listing

    class HnListing < BaseListing
      def score
        return self["points"] || 0
      end

      # base ranking algo
      def ranking
        self['ranking'] = score + self['num_comments']
      end
    end

  end
end
