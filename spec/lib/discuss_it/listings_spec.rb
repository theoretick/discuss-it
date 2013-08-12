require 'spec_helper'

describe "DiscussIt" do

  describe "Listings" do

    describe "Listing" do

      before(:all) do

        VCR.use_cassette("one_result_each", :record => :new_episodes) do
          @one_result_each = DiscussIt::DiscussItApi.new('http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/', '3')
        end

        @reddit_listing   = @one_result_each.all_listings.reddit.first
        @hn_listing       = @one_result_each.all_listings.hn.first
        @slashdot_listing = @one_result_each.all_listings.slashdot.first

      end

      describe 'initialization' do

        it "Listing.new should return a Listing object" do
          expect(DiscussIt::Listings::Listing.new({})).to be_an_instance_of(DiscussIt::Listings::Listing)
        end

        it "should not return a Listing object with no arg" do
          expect{ @hn_fetch.build_listing() }.not_to be_an_instance_of(DiscussIt::Listings::Listing)
        end

        it "should not return a Listing object with 1 + args" do
          expect{ @hn_fetch.build_listing(1,2) }.not_to be_an_instance_of(DiscussIt::Listings::Listing)
        end

      end

      describe 'accessors' do

        it "should have a location accessor on RedditListing" do
          expect(@reddit_listing.location).to eq('http://www.reddit.com/r/technology/comments/1j8h6p/edavid_a_robotic_system_built_by_researchers_at/')
        end

        it "should have a score accessor on RedditListing" do
          expect(@reddit_listing.score).to eq(4)
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
          @one_result_each = DiscussIt::DiscussItApi.new('http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/', '3')
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
          expect(@hn_listings.all?{|listing| listing.is_a?(DiscussIt::Listings::HnListing) } ).to be_true
        end

        it "should return only RedditListings from reddit method" do
          expect(@reddit_listings.all?{|listing| listing.is_a?(DiscussIt::Listings::RedditListing) }).to be_true
        end

        it "should return only SlashdotListings from slashdot method" do
          expect(@slashdot_listings.all?{|listing| listing.is_a?(DiscussIt::Listings::SlashdotListing) }).to be_true
        end

      end

      describe "tops" do

        it "should return 1 top listings for reddit" do
          expect(@one_result_each.all_listings.tops[:reddit]).to be_an_instance_of(DiscussIt::Listings::RedditListing)
        end

        it "should return 1 top listings for hn" do
          expect(@one_result_each.all_listings.tops[:hn]).to be_an_instance_of(DiscussIt::Listings::HnListing)
        end

        it "should return 1 top listings for slashdot" do
          expect(@one_result_each.all_listings.tops[:slashdot]).to be_an_instance_of(DiscussIt::Listings::SlashdotListing)
        end

      end

    end

  end

end