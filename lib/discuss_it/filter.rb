module DiscussIt

  class Filter

    # method to remove threads that have no comments
    def self.filter_threads(raw_results)

      good_results = [];
      bad_results = [];

      raw_results.each do |result|
        if result.num_comments == 0
          bad_results << result
        elsif result.comment_count == 0
          bad_results << result
        else
          good_results << result
        end
      end

      return good_results, bad_results

    end

  end

end
