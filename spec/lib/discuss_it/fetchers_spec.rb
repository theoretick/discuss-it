require 'spec_helper'

describe "DiscussIt" do

  describe "Fetcher" do

    describe "RedditFetch" do

      before(:all) do

        VCR.use_cassette("small_reddit_fetch", :record => :new_episodes) do
          @small_reddit = DiscussIt::Fetcher::RedditFetch.new('yorickpeterse.com/articles/debugging-with-pry/')
        end

        VCR.use_cassette("big_reddit_fetch", :record => :new_episodes) do
          @big_reddit = DiscussIt::Fetcher::RedditFetch.new('restorethefourth.net')
        end

      end

      describe "initialize" do

        it "should init with 1 arg" do
          expect(@big_reddit).to be_an_instance_of(DiscussIt::Fetcher::RedditFetch)
        end

        it "should not init with 0 arg" do
          expect{ DiscussIt::Fetcher::RedditFetch.new() }.to raise_error(ArgumentError)
        end

        it "should not init with 1+ args" do
          expect{ DiscussIt::Fetcher::RedditFetch.new("restorethefourth.net", "example.com") }.to raise_error(ArgumentError)
        end

      end

      describe "pull_out" do

        it "should return [data][children] from parent hash" do

          fake_reddit_raw = {
            "data" => {
              "children" => [
                { "foo" => "bar" }
              ]
            }
          }

          expect(@big_reddit.pull_out(fake_reddit_raw)).to eq([{"foo" => "bar"}])
        end

        it "should rescue and return empty hash if called on empty return" do
          expect(@big_reddit.pull_out(nil)).to eq([])
        end

      end

      describe "build_listing" do

        it "should return a RedditListing object" do
          fake_json = {}
          expect(@small_reddit.build_listing(fake_json)).to be_an_instance_of(DiscussIt::Listings::RedditListing)
        end

      end

      describe "build_all_listings" do

        it "should return an array of Listing objects" do
          expect(@small_reddit.build_all_listings).to be_an_instance_of(Array)
        end

        it "should have instance elements of RedditListing" do
          expect(@small_reddit.build_all_listings.first).to be_an_instance_of(DiscussIt::Listings::RedditListing)
        end

      end

    end


    describe "HnFetch" do

      before(:all) do

        VCR.use_cassette("small_hn_fetch", :record => :new_episodes) do
          @small_hn_fetch = DiscussIt::Fetcher::HnFetch.new('yorickpeterse.com/articles/debugging-with-pry/')
        end

        # TODO: is there a response with multiple HN responses? if so, find it.

      end

      describe "initialize" do

        it "should init with 1 arg" do
          expect(@small_hn_fetch).to be_an_instance_of(DiscussIt::Fetcher::HnFetch)
        end

        it "should not init with 0 arg" do
          expect{ DiscussIt::Fetcher::HnFetch.new() }.to raise_error(ArgumentError)
        end

        it "should not init with 1+ args" do
          expect{ DiscussIt::Fetcher::HnFetch.new("restorethefourth.net", "example.com") }.to raise_error(ArgumentError)
        end

      end

      describe "pull_out" do

        it "should return [results] from parent hash" do

          fake_hn_raw = {
              "results" => [
                { "foo" => "bar" }
              ]
            }

          expect(@small_hn_fetch.pull_out(fake_hn_raw)).to eq([{"foo" => "bar"}])
        end

        it "should rescue and return empty hash if called on empty return" do
          expect(@small_hn_fetch.pull_out(nil)).to eq([])
        end

      end

      describe "build_listing" do

        it "should return a HnListing object" do
          fake_json = {}
          expect(@small_hn_fetch.build_listing(fake_json)).to be_an_instance_of(DiscussIt::Listings::HnListing)
        end

      end

      describe "build_all_listings" do

        it "should be an array of Listing objects" do
          expect(@small_hn_fetch.build_all_listings).to be_an_instance_of(Array)
        end

        it "should have instance elements of HnListing" do
          expect(@small_hn_fetch.build_all_listings.first).to be_an_instance_of(DiscussIt::Listings::HnListing)
        end

      end

    end


    describe "SlashdotFetch" do

      before(:all) do

        VCR.use_cassette("small_slashdot", :record => :new_episodes) do
          @small_slashdot = DiscussIt::Fetcher::SlashdotFetch.new('http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/')
        end

        VCR.use_cassette("big_slashdot", :record => :new_episodes) do
          @big_slashdot = DiscussIt::Fetcher::SlashdotFetch.new('http://unknownlamer.org/')
        end

      end

      describe "initialization" do

        it "should init small fetch with 1 arg" do
          expect(@small_slashdot).to be_an_instance_of(DiscussIt::Fetcher::SlashdotFetch)
        end

        it "should init big fetch with 1 arg" do
          expect(@big_slashdot).to be_an_instance_of(DiscussIt::Fetcher::SlashdotFetch)
        end

        it "should not init with 0 arg" do
          expect{ DiscussIt::Fetcher::SlashdotFetch.new() }.to raise_error(ArgumentError)
        end

        it "should not init with 1+ args" do
          expect{ DiscussIt::Fetcher::SlashdotFetch.new("restorethefourth.net", "example.com") }.to raise_error(ArgumentError)
        end
      end

      describe "build_listing" do

        it "should return a SlashdotListing object" do
          fake_json = {}
          expect(@small_slashdot.build_listing(fake_json)).to be_an_instance_of(DiscussIt::Listings::SlashdotListing)
        end

      end

      describe "build_all_listings" do

        it "should be an array of Listing objects" do
          expect(@big_slashdot.build_all_listings).to be_an_instance_of(Array)
        end

        it "should have instance elements of SlashdotListing" do
          expect(@big_slashdot.build_all_listings.first).to be_an_instance_of(DiscussIt::Listings::SlashdotListing)
        end

      end

    end


describe "Fetch" do

  describe "http_add" do

    it "should add http if not found" do
      expect(DiscussIt::Fetcher::Fetch.ensure_http('restorethefourth.net')).to eq('http://restorethefourth.net')
    end

    it "should not add http if 'http://' found" do
      expect(DiscussIt::Fetcher::Fetch.ensure_http('http://restorethefourth.net')).to eq('http://restorethefourth.net')
    end

    it "should not add http if 'https://' found" do
      expect(DiscussIt::Fetcher::Fetch.ensure_http('https://restorethefourth.net')).to eq('https://restorethefourth.net')
    end

  end

  describe "parse" do

    it "should return a ruby hash with correctly formed response" do
      fake_json = {"name" => "discussit"}.to_json
      expect(DiscussIt::Fetcher::Fetch.parse(fake_json)).to be_an_instance_of(Hash)
    end

    it "should return a ruby array with empty response" do
      fake_nil_json = [].to_json
      expect(DiscussIt::Fetcher::Fetch.parse(fake_nil_json)).to be_an_instance_of(Array)
    end

  end

  describe "get_response", :vcr do

    before(:all) do
      @reddit_api_url = 'http://www.reddit.com/api/info.json?url='
      @hn_api_url = 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]='
      @slashdot_api_url = 'https://slashdot-api.herokuapp.com/slashdot_postings/search?url='
    end

    it "should return ruby hash from reddit string", :vcr do
      expect(DiscussIt::Fetcher::Fetch.get_response(@reddit_api_url, 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    it "should return ruby hash from a nil reddit string", :vcr do
      expect(DiscussIt::Fetcher::Fetch.get_response(@reddit_api_url, '')).to be_an_instance_of(Hash)
    end

    it "should return ruby hash from hn string", :vcr do
      expect(DiscussIt::Fetcher::Fetch.get_response(@hn_api_url, 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    # FIXME: make a special catch for nil hn? weird valid case that returns results, potentially bad
    it "should return ruby hash from a nil hn string" do
      expect(DiscussIt::Fetcher::Fetch.get_response(@hn_api_url, '')).to be_an_instance_of(Hash)
    end

    # FIXME: this should be a hash like everything else, TODO: serialize JSON response
    it "should return ruby hash from slashdot string", :vcr do
      expect(DiscussIt::Fetcher::Fetch.get_response(@slashdot_api_url, 'http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/')).to be_an_instance_of(Array)
    end

    it "should return ruby hash from a nil slashdot string" do
      expect(DiscussIt::Fetcher::Fetch.get_response(@slashdot_api_url, '')).to be_an_instance_of(Array)
    end

  end

end



  end

end
