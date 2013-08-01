require 'spec_helper'

describe "Fetch" do

  describe "http_add" do

    it "should add http if not found" do
      expect(Fetch.ensure_http('restorethefourth.net')).to eq('http://restorethefourth.net')
    end

    it "should not add http if found" do
      expect(Fetch.ensure_http('http://restorethefourth.net')).to eq('http://restorethefourth.net')
    end

  end

  describe "parse" do

    # FIXME: this test sucks
    it "should return a ruby hash" do
      fake_json = {"name" => "discussit"}.to_json
      expect(Fetch.parse(fake_json)).to be_an_instance_of(Hash)
    end

  end

  describe "get_response", :vcr do

    before(:all) do
      @reddit_api_url = 'http://www.reddit.com/api/info.json?url='
      @hn_api_url = 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]='
    end

    it "should return ruby hash from reddit string", :vcr do
      expect(Fetch.get_response(@reddit_api_url, 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    it "should not return ruby hash from a nil reddit string", :vcr do
      expect(Fetch.get_response(@reddit_api_url, '')).to eq({"kind"=>"Listing", "data"=>{"modhash"=>"", "children"=>[], "after"=>nil, "before"=>nil}})
    end

    it "should return ruby hash from hn string", :vcr do
      expect(Fetch.get_response(@hn_api_url, 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    # FIXME: make this test better, it currently checks length, is invalidated by time marker on api response
    it "should return ruby hash from a nil hn string" do
      expect(Fetch.get_response(@hn_api_url, '')).to be_an_instance_of(Hash)
    end
  end
end

describe "RedditFetch" do

  before(:all) do

    VCR.use_cassette("small_reddit_init", :record => :new_episodes) do
      @small_reddit_init = RedditFetch.new('yorickpeterse.com/articles/debugging-with-pry/')
    end

    VCR.use_cassette("big_reddit_init", :record => :new_episodes) do
      @big_reddit_init = RedditFetch.new('restorethefourth.net')
    end

  end

  describe "initialize" do

    it "should init with 1 arg" do
      expect(@big_reddit_init).to be_an_instance_of(RedditFetch)
    end

    it "should not init with 0 arg" do
      expect{ RedditFetch.new() }.not_to be_an_instance_of(RedditFetch)
    end

    it "should not init with 1+ args" do
      expect{ RedditFetch.new("restorethefourth.net", "example.com") }.not_to be_an_instance_of(RedditFetch)
    end
  end

  describe "pull_out" # do
  #   it "should return [data][children] from parent hash"
  # end

  describe "build_listing" do

    it "should return a RedditListing object" do
      fake_json = {}
      expect(@small_reddit_init.build_listing(fake_json)).to be_an_instance_of(RedditListing)
    end

  end

  describe "build_all_listings" do

    it "should return an array of Listing objects" do
      expect(@small_reddit_init.build_all_listings).to be_an_instance_of(Array)
    end

  end

end

describe "HnFetch" do

  before(:all) do

    VCR.use_cassette("hn_fetch", :record => :new_episodes) do
      @hn_fetch = HnFetch.new('yorickpeterse.com/articles/debugging-with-pry/')
    end

  end

  describe "initialize" do

    it "should init with 1 arg" do
      expect(@hn_fetch).to be_an_instance_of(HnFetch)
    end

    it "should not init with 0 arg" do
      expect{ HnFetch.new() }.not_to be_an_instance_of(HnFetch)
    end

    it "should not init with 1+ args" do
      expect{ HnFetch.new("restorethefourth.net", "example.com") }.not_to be_an_instance_of(HnFetch)
    end
  end

  describe "pull_out" # do
  #   it "should return [results] from parent hash"
  # end

  describe "build_listing" do

    it "should return a HnListing object" do
      fake_json = {}
      expect(@hn_fetch.build_listing(fake_json)).to be_an_instance_of(HnListing)
    end

  end

  describe "build_all_listings" do

    it "should be an array of Listing objects" do
      expect(@hn_fetch.build_all_listings).to be_an_instance_of(Array)
    end

    it "should have instance elements of Listing" do
      expect(@hn_fetch.build_all_listings.first).to be_an_instance_of(HnListing)
    end

    it "should contain Listing objects" # do
      # expect(@hn_fetch.build_all_listings).to contain(HnListing)
    # end

    it "should not return an array of Listing objects with no args"

  end

end

describe "Listing" do

  before(:all) do
    VCR.use_cassette("one_result_each", :record => :new_episodes) do
      @one_result_each = DiscussItApi.new('yorickpeterse.com/articles/debugging-with-pry/')
    end

    @reddit_listing = @one_result_each.all_listings.reddit.first
    @hn_listing = @one_result_each.all_listings.hn.first

  end

  describe 'initialization' do

    it "Listing.new should return a Listing object" do
      expect(Listing.new({})).to be_an_instance_of(Listing)
    end

    it "should not return a Listing object with no arg" do
      expect{ @hn_fetch.build_listing() }.not_to be_an_instance_of(Listing)
    end

    it "should not return a Listing object with 1 + args" do
      expect{ @hn_fetch.build_listing(1,2) }.not_to be_an_instance_of(Listing)
    end

  end

  describe 'accessors' do

    it "should have a location accessor on RedditListing" do
      expect(@reddit_listing.location).to eq('http://www.reddit.com/r/ruby/comments/mqtwx/debugging_with_pry/')
    end

    it "should have a score accessor on RedditListing" do
      expect(@reddit_listing.score).to eq(17)
    end

    it "should have a location accessor on HnListing" do
      expect(@hn_listing.location).to eq('http://news.ycombinator.com/item?id=3282367')
    end

    it "should have a score accessor on HnListing" do
      expect(@hn_listing.score).to eq(2)
    end

  end

  it 'should not be writeable' # do
  #   expect{ @hn_listing.score = 100 }.to raise_error
  # end

end

describe "ListingCollection" do

  before(:all) do
    VCR.use_cassette("one_result_each", :record => :new_episodes) do
      @one_result_each = DiscussItApi.new('yorickpeterse.com/articles/debugging-with-pry/')
    end

    @reddit_listing = @one_result_each.all_listings.reddit
    @hn_listing = @one_result_each.all_listings.hn
  end

  describe "initialization" do

    it "should initialize as all_listings on DiscussItApi" do
      expect(@one_result_each.all_listings).to be_an_instance_of(ListingCollection)
    end

  end

  describe "accessors" do

    it "should return only HnListings from hn method" do
      # FIXME: iterate through each instead of just first
      expect(@hn_listing.all?{|listing| listing.is_a?(HnListing) } ).to be_true
    end

    it "should return only RedditListings from reddit method" do
      # FIXME: iterate through each instead of just first
      expect(@reddit_listing.all?{|listing| listing.is_a?(RedditListing) }).to be_true
    end

  end

end

describe "DiscussItApi" do

  before(:all) do

    VCR.use_cassette("one_result_each", :record => :new_episodes) do
      @one_result_each = DiscussItApi.new('yorickpeterse.com/articles/debugging-with-pry/')
    end

    VCR.use_cassette("many_results_reddit", :record => :new_episodes) do
      @many_results_reddit = DiscussItApi.new('restorethefourth.net')
    end

    VCR.use_cassette("many_results_all", :record => :new_episodes) do
      @many_results_all = DiscussItApi.new('http://www.ministryoftruth.me.uk/2013/07/24/cameron-porn-advisors-website-hacked-threatenslibels-blogger/')
    end

  end

  describe "initialization", :vcr do

    it "should not initialize without an argument" do
      expect{ DiscussItApi.new() }.to_not be_an_instance_of(DiscussItApi)
    end

    it "should initialize with 1 arg" do
      expect(DiscussItApi.new("http://restorethefourth.net/")).to be_an_instance_of(DiscussItApi)
    end

    it "should not initialize with 2 args" do
      expect {
        DiscussItApi.new('http://example.com','http://example.org')
      }.to raise_error(ArgumentError, "wrong number of arguments (2 for 1)")
    end
  end

  describe "find_all", :vcr do

    it "should return 2 results for multisite small listings" do
      expect(@one_result_each.find_all.all.length).to eq(2)
    end

    it "should return 28 results for singlesite large listings" do
      expect(@many_results_reddit.find_all.all.length).to eq(28)
    end

    it "should return 14 results for multisite large listings" do
      expect(@many_results_all.find_all.all.length).to eq(14)
    end

  end

  describe "find_top" do

    it "should return 2 results for multisite small listings" do
      # FIXME: this test sucks
      expect(@one_result_each.find_top.keys.length).to eq(2)
    end

    it "should return 1 results for singlesite large listings" do
      expect(@many_results_reddit.find_top.keys.length).to eq(1)
    end

    it "should return 2 results for multisite large listings" do
      expect(@many_results_all.find_top.keys.length).to eq(2)
    end

  end

end
