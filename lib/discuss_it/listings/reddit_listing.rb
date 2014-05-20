
require_relative 'base'

#----------------------------------------------------------------------
# Listing class for Reddit with custom accessors
#----------------------------------------------------------------------
module DiscussIt

  module Listing

    class RedditListing < BaseListing
      def score
        return self["score"] || 0
      end

      # for custom ranking algorithm
      def ranking
        # self["score"] + ( subreddit_subscribers(self["subreddit"]) + self["num_comments"] )
        self['ranking'] = score + self['num_comments']
      end
    end

  end
end