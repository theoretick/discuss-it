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

      describe "initialize", :vcr do

        it "inits with 1 arg" do
          expect(@big_reddit).to be_an_instance_of(DiscussIt::Fetcher::RedditFetch)
        end

        it "wont init with 0 arg" do
          expect{ DiscussIt::Fetcher::RedditFetch.new() }.to raise_error(ArgumentError)
        end

        it "wont init with 1+ args" do
          expect{ DiscussIt::Fetcher::RedditFetch.new("restorethefourth.net", "example.com") }.to raise_error(ArgumentError)
        end

      end

      describe "#pull_out" do

        it "returns [data][children] from parent hash" do

          fake_reddit_raw = {
            "data" => {
              "children" => [
                { "foo" => "bar" }
              ]
            }
          }

          expect(@big_reddit.pull_out(fake_reddit_raw)).to eq([
            {"foo" => "bar"}
          ])
        end

        it "rescues and returns empty hash if called on empty return" do
          expect(@big_reddit.pull_out(nil)).to eq([])
        end

      end

      describe "#build_listing" do

        it "returns a RedditListing object" do
          fake_json = {}
          expect(@small_reddit.build_listing(fake_json)).to be_an_instance_of(DiscussIt::Listing::RedditListing)
        end

      end

      describe "#build_all_listings" do

        it "returns an array of Listing objects" do
          expect(@small_reddit.build_all_listings).to be_an_instance_of(Array)
        end

        it "has listing instances of RedditListing" do
          expect(@small_reddit.build_all_listings.first).to be_an_instance_of(DiscussIt::Listing::RedditListing)
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

      describe "#initialize", :vcr do

        # FIXME: specify args. what are they
        it "inits with " do
          expect(DiscussIt::Fetcher::HnFetch.new("restorethefourth.net")).to be_an_instance_of(DiscussIt::Fetcher::HnFetch)
        end

        it "wont init with 0 arg" do
          expect{ DiscussIt::Fetcher::HnFetch.new() }.to raise_error(ArgumentError)
        end

        it "wont init with 1+ args" do
          expect{ DiscussIt::Fetcher::HnFetch.new("restorethefourth.net", "example.com") }.to raise_error(ArgumentError)
        end

      end

      describe "#pull_out" do

        it "returns [results] from parent hash" do

          fake_hn_raw = {
              "results" => [
                { "foo" => "bar" }
              ]
            }

          expect(@small_hn_fetch.pull_out(fake_hn_raw)).to eq([{"foo" => "bar"}])
        end

        it "rescues and returns empty hash if called on empty return" do
          expect(@small_hn_fetch.pull_out(nil)).to eq([])
        end

      end

      describe "#build_listing" do

        it "returns a HnListing object" do
          fake_json = {}
          expect(@small_hn_fetch.build_listing(fake_json)).to be_an_instance_of(DiscussIt::Listing::HnListing)
        end

      end

      describe "#build_all_listings" do

        it "is an array of Listing objects" do
          expect(@small_hn_fetch.build_all_listings).to be_an_instance_of(Array)
        end

        it "has listing instances of HnListing" do
          expect(@small_hn_fetch.build_all_listings.first).to be_an_instance_of(DiscussIt::Listing::HnListing)
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

      describe "#initialization" do

        it "inits small fetch with 1 arg" do
          expect(@small_slashdot).to be_an_instance_of(DiscussIt::Fetcher::SlashdotFetch)
        end

        it "inits big fetch with 1 arg" do
          expect(@big_slashdot).to be_an_instance_of(DiscussIt::Fetcher::SlashdotFetch)
        end

        it "wont init with 0 arg" do
          expect{ DiscussIt::Fetcher::SlashdotFetch.new() }.to raise_error(ArgumentError)
        end

        it "wont init with 1+ args" do
          expect{ DiscussIt::Fetcher::SlashdotFetch.new("restorethefourth.net", "example.com") }.to raise_error(ArgumentError)
        end
      end

      describe "#build_listing" do

        it "returns a SlashdotListing object" do
          fake_json = {}
          expect(@small_slashdot.build_listing(fake_json)).to be_an_instance_of(DiscussIt::Listing::SlashdotListing)
        end

      end

      describe "#build_all_listings" do

        it "is an array of Listing objects" do
          expect(@big_slashdot.build_all_listings).to be_an_instance_of(Array)
        end

        it "has listing instances of SlashdotListing" do
          expect(@big_slashdot.build_all_listings.first).to be_an_instance_of(DiscussIt::Listing::SlashdotListing)
        end

      end

    end


describe "BaseFetch" do

  describe "#ensure_http" do

    before(:all) do
      @fetcher = DiscussIt::Fetcher::BaseFetch.new
    end

    it "adds http if not found" do
      expect(@fetcher.ensure_http('restorethefourth.net')).to eq('http://restorethefourth.net')
    end

    it "wont add http if 'http://' is found" do
      expect(@fetcher.ensure_http('http://restorethefourth.net')).to eq('http://restorethefourth.net')
    end

    it "wont add http if 'https://' is found" do
      expect(@fetcher.ensure_http('https://restorethefourth.net')).to eq('https://restorethefourth.net')
    end

  end

  describe "#parse" do

    before(:all) do
      @fetcher = DiscussIt::Fetcher::BaseFetch.new
    end

    it "returns a ruby hash with correctly formed response" do
      fake_json = {"name" => "discussit"}.to_json
      expect(@fetcher.parse(fake_json)).to be_an_instance_of(Hash)
    end

    it "returns a ruby array with empty response" do
      fake_nil_json = [].to_json
      expect(@fetcher.parse(fake_nil_json)).to be_an_instance_of(Array)
    end

    # TODO: add test for rescue JSON::ParserError => e

  end

  describe "#get_response", :vcr do

    before(:all) do
      @reddit_api_url   = 'http://www.reddit.com/api/info.json?url='
      @hn_api_url       = 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]='
      @slashdot_api_url = 'https://slashdot-api.herokuapp.com/search?url='

      @fetcher = DiscussIt::Fetcher::BaseFetch.new
    end

    it "returns no results gracefully from reddit string" do
      expect(@fetcher.get_response(@reddit_api_url, 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    it "returns no results gracefully from a nil reddit string" do
      expect(@fetcher.get_response(@reddit_api_url, '')).to be_an_instance_of(Hash)
    end

    it "returns valid hash content from hn string" do
      expect(@fetcher.get_response(@hn_api_url, 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    # FIXME: make a special catch for nil hn? weird valid case that returns results, potentially bad
    it "returns no results gracefully from a nil hn string" do
      expect(@fetcher.get_response(@hn_api_url, '')).to be_an_instance_of(Hash)
    end

    # TODO: serialize JSON response
    it "returns ruby hash from slashdot string" do
      expect(@fetcher.get_response(@slashdot_api_url, 'http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/')).to be_an_instance_of(Array)
    end

    it "returns no results gracefully from a nil slashdot string" do
      expect(@fetcher.get_response(@slashdot_api_url, '')).to be_an_instance_of(Array)
    end

    # TODO: stub get => raise error

  end

end



  end

end
