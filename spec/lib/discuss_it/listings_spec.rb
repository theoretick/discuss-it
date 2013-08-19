require 'spec_helper'

describe "DiscussIt" do

  describe "Listing" do

    describe "Listing" do

      before(:all) do
        @reddit_listing   = DiscussIt::Listing::RedditListing.new(
          {"domain"=>"singularityhub.com", "banned_by"=>nil, "media_embed"=>{}, "subreddit"=>"technology", "selftext_html"=>nil, "selftext"=>"", "likes"=>nil, "link_flair_text"=>nil, "id"=>"1j8h6p", "clicked"=>false, "stickied"=>false, "title"=> "e-David, a robotic system built by researchers at the U of Konstanz, employs a variety of styles to produce paintings remarkably similar to their human counterparts -- \"the final products seem to display that perfectly imperfect quality we generally associate with human works of art\"", "media"=>nil, "score"=>3, "approved_by"=>nil, "over_18"=>false, "hidden"=>false, "thumbnail"=>"", "subreddit_id"=>"t5_2qh16", "edited"=>false, "link_flair_css_class"=>nil, "author_flair_css_class"=>nil, "downs"=>11, "saved"=>false, "is_self"=>false, "permalink"=> "/r/technology/comments/1j8h6p/edavid_a_robotic_system_built_by_researchers_at/", "name"=>"t3_1j8h6p", "created"=>1375074720.0, "url"=> "http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/", "author_flair_text"=>nil, "author"=>"mepper", "created_utc"=>1375045920.0, "ups"=>14, "num_comments"=>0, "num_reports"=>nil, "distinguished"=>nil}
        )
        @hn_listing       = DiscussIt::Listing::HnListing.new(
          {"username"=>"chewxy", "parent_sigid"=>nil, "domain"=>"singularityhub.com", "title"=>"Robots paint with flaws too, like humans", "url"=>"http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/", "text"=>nil, "discussion"=>nil, "id"=>6118451, "parent_id"=>nil, "points"=>2, "create_ts"=>"2013-07-28T22:58:13Z", "num_comments"=>0, "cache_ts"=>"2013-08-05T07:36:41Z", "_id"=>"6118451-780d6", "type"=>"submission", "_noindex"=>false, "_update_ts"=>1375688234296273}
          )
        @slashdot_listing = DiscussIt::Listing::SlashdotListing.new(
          {"id"=>112, "title"=>"Robot Produces Paintings With That ImperfectHuman Look - Slashdot", "permalink"=>"http://hardware.slashdot.org/story/13/07/28/2056210/robot-produces-paintings-with-that-imperfect-human-look", "created_at"=>"2013-08-02T02:58:52.944Z", "updated_at"=>"2013-08-02T02:58:52.944Z", "site"=>"slashdot", "author"=>"timothy", "comment_count"=>74, "post_date"=>"on Sunday July 28, 2013 @04:57PM"}
        )

      end

      describe 'initialization' do

        it "Listing.new should return a Listing object" do
          expect(DiscussIt::Listing::BaseListing.new({})).to be_an_instance_of(DiscussIt::Listing::BaseListing)
        end

      end

      describe 'accessors' do

        it "should have a location accessor on RedditListing" do
          expect(@reddit_listing.location).to eq('http://www.reddit.com/r/technology/comments/1j8h6p/edavid_a_robotic_system_built_by_researchers_at/')
        end

        it "should have a score accessor on RedditListing" do
          expect(@reddit_listing.score).to eq(3)
        end

        it "should have a subreddit accessor on RedditListing" do
          expect(@reddit_listing.subreddit).to eq('technology')
        end

        it "should have a location accessor on HnListing" do
          expect(@hn_listing.location).to eq('http://news.ycombinator.com/item?id=6118451')
        end

        it "should have a score accessor on HnListing" do
          expect(@hn_listing.score).to eq(2)
        end

        it "should have a location accessor on SlashdotListing" do
          expect(@slashdot_listing.location).to eq('http://hardware.slashdot.org/story/13/07/28/2056210/robot-produces-paintings-with-that-imperfect-human-look')
        end

        it "should have a score accessor on SlashdotListing" do
          expect(@slashdot_listing.score).to eq(74)
        end

      end

    end

    describe "ListingCollection" do

      before(:all) do

        VCR.use_cassette("one_result_each", :record => :new_episodes) do
          @one_result_each = DiscussIt::DiscussItApi.new('http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/')
        end

        @reddit_listings   = @one_result_each.all_listings.reddit
        @hn_listings       = @one_result_each.all_listings.hn
        @slashdot_listings = @one_result_each.all_listings.slashdot

      end

      describe "initialization" do

        it "should initialize as all_listings on DiscussItApi" do
          expect(@one_result_each.all_listings).to be_an_instance_of(DiscussIt::ListingCollection)
        end

      end

      describe "accessors" do

        it "should return only HnListings from hn method" do
          expect(@hn_listings.all? { |listing|
            listing.is_a?(DiscussIt::Listing::HnListing)
          }).to be_true
        end

        it "should return only RedditListings from reddit method" do
          expect(@reddit_listings.all? { |listing|
            listing.is_a?(DiscussIt::Listing::RedditListing)
          }).to be_true
        end

        it "should return only SlashdotListings from slashdot method" do
          expect(@slashdot_listings.all? { |listing|
            listing.is_a?(DiscussIt::Listing::SlashdotListing)
          }).to be_true
        end

      end

      describe "tops" do

        it "should return 1 top listings for reddit" do
          expect(@one_result_each.all_listings.tops.select { |listing|
            listing.class == DiscussIt::Listing::RedditListing }.length).to eq(1)
        end

        it "should return 1 top listings for hn" do
          expect(@one_result_each.all_listings.tops.select { |listing|
            listing.class == DiscussIt::Listing::HnListing }.length).to eq(1)
        end

        it "should return 1 top listings for slashdot" do
          expect(@one_result_each.all_listings.tops.select { |listing|
            listing.class == DiscussIt::Listing::SlashdotListing }.length).to eq(1)
        end

      end

    end

  end

end