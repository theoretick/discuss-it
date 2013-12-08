require 'spec_helper'

describe "DiscussIt" do

  describe "Listing" do

    describe "Listing" do

      let(:reddit_listing ) {
        DiscussIt::Listing::RedditListing.new({
          "subreddit" => "technology",
          "title" => "e-David, a robotic system built by researchers at the U of Konstanz, employs a variety of styles to produce paintings remarkably similar to their human counterparts -- \"the final products seem to display that perfectly imperfect quality we generally associate with human works of art\"",
          "permalink" => "/r/technology/comments/1j8h6p/edavid_a_robotic_system_built_by_researchers_at/",
          "url" => "http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/",
          "ups" => 14,
          "downs" => 11,
          "score" => 3,
          "num_comments" => 0
        })
       }

      let(:hn_listing) {
        DiscussIt::Listing::HnListing.new({
          "title" => "Robots paint with flaws too, like humans",
          "url" => "http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/",
          "points" => 2,
          "num_comments" => 0
        })
      }

      let(:slashdot_listing) {
        DiscussIt::Listing::SlashdotListing.new({
          "title" => "Robot Produces Paintings With That Imperfect Human Look - Slashdot",
          "permalink" => "http://hardware.slashdot.org/story/13/07/28/2056210/robot-produces-paintings-with-that-imperfect-human-look",
          "comment_count" => 74
        })
      }

      describe '#initialize' do

        it "returns a Listing object" do
          expect(DiscussIt::Listing::RedditListing.new({})).to    be_a_kind_of(DiscussIt::Listing::BaseListing)
          expect(DiscussIt::Listing::HnListing.new({})).to        be_a_kind_of(DiscussIt::Listing::BaseListing)
          expect(DiscussIt::Listing::SlashdotListing.new({})).to  be_a_kind_of(DiscussIt::Listing::BaseListing)
        end

      end

      describe 'accessors' do

        xit "has a location accessor for any descendant" do
          expect(reddit_listing.location).to eq(
            'http://www.reddit.com/r/technology/comments/1j8h6p/edavid_a_robotic_system_built_by_researchers_at/')
          expect(hn_listing.location).to eq(
            'http://news.ycombinator.com/item?id=6118451')
          expect(slashdot_listing.location).to eq(
            'http://hardware.slashdot.org/story/13/07/28/2056210/robot-produces-paintings-with-that-imperfect-human-look')
        end

        xit "has a ranking accessor for any descendant" do
          expect(reddit_listing.ranking).to    be_kind_of(Fixnum)
          expect(hn_listing.ranking).to        be_kind_of(Fixnum)
          expect(slashdot_listing.ranking).to  be_kind_of(Fixnum)
        end

        it "has a subreddit accessor on RedditListing" do
          expect(reddit_listing.subreddit).to eq('technology')
        end

      end

    end

    describe "ListingCollection" do

      let(:one_result_each) {
        DiscussIt::Fetcher::RedditFetch.any_instance.stub(:get_response) { {} }
        DiscussIt::Fetcher::HnFetch.any_instance.stub(:get_response) { {} }
        DiscussIt::Fetcher::SlashdotFetch.any_instance.stub(:get_response) { {} }

        DiscussIt::Fetcher::RedditFetch.any_instance.stub(:listings).and_return([
          DiscussIt::Listing::RedditListing.new({
            "subreddit" => "technology",
            "title" => "e-David, a robotic system built by researchers at the U of Konstanz, employs a variety of styles to produce paintings remarkably similar to their human counterparts -- \"the final products seem to display that perfectly imperfect quality we generally associate with human works of art\"",
            "permalink" => "/r/technology/comments/1j8h6p/edavid_a_robotic_system_built_by_researchers_at/",
            "url" => "http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/",
            "ups" => 14,
            "downs" => 11,
            "score" => 3,
            "num_comments" => 0
          })
        ])
        DiscussIt::Fetcher::HnFetch.any_instance.stub(:listings).and_return([
          DiscussIt::Listing::HnListing.new({
            "title" => "Robots paint with flaws too, like humans",
            "url" => "http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/",
            "points" => 2,
            "num_comments" => 0
          })
        ])
        DiscussIt::Fetcher::SlashdotFetch.any_instance.stub(:listings).and_return([
          DiscussIt::Listing::SlashdotListing.new({
            "title" => "Robot Produces Paintings With That Imperfect Human Look - Slashdot",
            "permalink" => "http://hardware.slashdot.org/story/13/07/28/2056210/robot-produces-paintings-with-that-imperfect-human-look",
            "comment_count" => 74
          })
        ])

        return DiscussIt::DiscussItApi.new('http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/')
      }

      let(:reddit_listings) { one_result_each.listings.reddit }
      let(:hn_listings) { one_result_each.listings.hn }
      let(:slashdot_listings) { one_result_each.listings.slashdot }

      describe "#initialize" do

        it "equates to listings on DiscussItApi" do
          expect(one_result_each.listings).to be_an_instance_of(DiscussIt::ListingCollection)
        end

      end

      describe "accessors" do

        let(:has_only_hn_listings) {
          hn_listings.all? do |listing|
            listing.instance_of?(DiscussIt::Listing::HnListing)
          end
        }
        let(:has_only_reddit_listings) {
          reddit_listings.all? do |listing|
            listing.instance_of?(DiscussIt::Listing::RedditListing)
          end
        }
        let(:has_only_slashdot_listings) {
          slashdot_listings.all? do |listing|
            listing.instance_of?(DiscussIt::Listing::SlashdotListing)
          end
        }

        it "returns only HnListings from hn method" do
          expect(has_only_hn_listings).to be_true
        end

        it "returns only RedditListings from reddit method" do
          expect(has_only_reddit_listings).to be_true
        end

        it "returns only SlashdotListings from slashdot method" do
          expect(has_only_slashdot_listings).to be_true
        end

      end

      describe "#tops" do

        let(:reddit_listings_in_results) {
          one_result_each.listings.tops.select do |listing|
            listing.class == DiscussIt::Listing::RedditListing
          end
        }
        let(:hn_listings_in_results) {
          one_result_each.listings.tops.select do |listing|
            listing.class == DiscussIt::Listing::HnListing
          end
        }
        let(:slashdot_listings_in_results) {
          one_result_each.listings.tops.select do |listing|
            listing.class == DiscussIt::Listing::SlashdotListing
          end
        }

        it "returns a top listing for reddit" do
          expect(reddit_listings_in_results).to have_at_least(1).things
        end

        it "returns a top listing for hn" do
          expect(hn_listings_in_results).to have_at_least(1).things
        end

        it "returns a top listing for slashdot" do
          expect(slashdot_listings_in_results).to have_at_least(1).things
        end

      end

    end

  end

end