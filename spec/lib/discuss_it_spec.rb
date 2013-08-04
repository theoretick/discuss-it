require 'spec_helper'

describe "Fetch" do

  describe "http_add" do

    it "should add http if not found" do
      expect(Fetch.ensure_http('restorethefourth.net')).to eq('http://restorethefourth.net')
    end

    it "should not add http if 'http://' found" do
      expect(Fetch.ensure_http('http://restorethefourth.net')).to eq('http://restorethefourth.net')
    end

    it "should not add http if 'https://' found" do
      expect(Fetch.ensure_http('https://restorethefourth.net')).to eq('https://restorethefourth.net')
    end

  end

  describe "parse" do

    it "should return a ruby hash with correctly formed response" do
      fake_json = {"name" => "discussit"}.to_json
      expect(Fetch.parse(fake_json)).to be_an_instance_of(Hash)
    end

    it "should return a ruby array with empty response" do
      fake_nil_json = [].to_json
      expect(Fetch.parse(fake_nil_json)).to be_an_instance_of(Array)
    end

  end

  describe "get_response", :vcr do

    before(:all) do
      @reddit_api_url = 'http://www.reddit.com/api/info.json?url='
      @hn_api_url = 'http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]='
      @slashdot_api_url = 'https://slashdot-api.herokuapp.com/slashdot_postings/search?url='
    end

    it "should return ruby hash from reddit string", :vcr do
      expect(Fetch.get_response(@reddit_api_url, 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    it "should return ruby hash from a nil reddit string", :vcr do
      expect(Fetch.get_response(@reddit_api_url, '')).to be_an_instance_of(Hash)
    end

    it "should return ruby hash from hn string", :vcr do
      expect(Fetch.get_response(@hn_api_url, 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    # FIXME: make a special catch for nil hn? weird valid case that returns results, potentially bad
    it "should return ruby hash from a nil hn string" do
      expect(Fetch.get_response(@hn_api_url, '')).to be_an_instance_of(Hash)
    end

    # FIXME: this should be a hash like everything else, TODO: serialize JSON response
    it "should return ruby hash from slashdot string", :vcr do
      expect(Fetch.get_response(@slashdot_api_url, 'http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/')).to be_an_instance_of(Array)
    end

    it "should return ruby hash from a nil slashdot string" do
      expect(Fetch.get_response(@slashdot_api_url, '')).to be_an_instance_of(Array)
    end

  end

end

describe "RedditFetch" do

  before(:all) do

    VCR.use_cassette("small_reddit_fetch", :record => :new_episodes) do
      @small_reddit = RedditFetch.new('yorickpeterse.com/articles/debugging-with-pry/')
    end

    VCR.use_cassette("big_reddit_fetch", :record => :new_episodes) do
      @big_reddit = RedditFetch.new('restorethefourth.net')
    end

  end

  describe "initialize" do

    it "should init with 1 arg" do
      expect(@big_reddit).to be_an_instance_of(RedditFetch)
    end

    it "should not init with 0 arg" do
      expect{ RedditFetch.new() }.not_to be_an_instance_of(RedditFetch)
    end

    it "should not init with 1+ args" do
      expect{ RedditFetch.new("restorethefourth.net", "example.com") }.not_to be_an_instance_of(RedditFetch)
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
      expect(@small_reddit.build_listing(fake_json)).to be_an_instance_of(RedditListing)
    end

  end

  describe "build_all_listings" do

    it "should return an array of Listing objects" do
      expect(@small_reddit.build_all_listings).to be_an_instance_of(Array)
    end

    it "should have instance elements of RedditListing" do
      expect(@small_reddit.build_all_listings.first).to be_an_instance_of(RedditListing)
    end

  end

end

describe "HnFetch" do

  before(:all) do

    VCR.use_cassette("small_hn_fetch", :record => :new_episodes) do
      @small_hn_fetch = HnFetch.new('yorickpeterse.com/articles/debugging-with-pry/')
    end

    # TODO: is there a response with multiple HN responses? if so, find it.

  end

  describe "initialize" do

    it "should init with 1 arg" do
      expect(@small_hn_fetch).to be_an_instance_of(HnFetch)
    end

    it "should not init with 0 arg" do
      expect{ HnFetch.new() }.not_to be_an_instance_of(HnFetch)
    end

    it "should not init with 1+ args" do
      expect{ HnFetch.new("restorethefourth.net", "example.com") }.not_to be_an_instance_of(HnFetch)
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
      expect(@small_hn_fetch.build_listing(fake_json)).to be_an_instance_of(HnListing)
    end

  end

  describe "build_all_listings" do

    it "should be an array of Listing objects" do
      expect(@small_hn_fetch.build_all_listings).to be_an_instance_of(Array)
    end

    it "should have instance elements of HnListing" do
      expect(@small_hn_fetch.build_all_listings.first).to be_an_instance_of(HnListing)
    end

  end

end

describe "SlashdotFetch" do

  before(:all) do

    VCR.use_cassette("small_slashdot", :record => :new_episodes) do
      @small_slashdot = SlashdotFetch.new('http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/')
    end

    VCR.use_cassette("big_slashdot", :record => :new_episodes) do
      @big_slashdot = SlashdotFetch.new('http://unknownlamer.org/')
    end

  end

  describe "initialization" do

    it "should init small fetch with 1 arg" do
      expect(@small_slashdot).to be_an_instance_of(SlashdotFetch)
    end

    it "should init big fetch with 1 arg" do
      expect(@big_slashdot).to be_an_instance_of(SlashdotFetch)
    end

    it "should not init with 0 arg" do
      expect{ SlashdotFetch.new() }.not_to be_an_instance_of(SlashdotFetch)
    end

    it "should not init with 1+ args" do
      expect{ SlashdotFetch.new("restorethefourth.net", "example.com") }.not_to be_an_instance_of(SlashdotFetch)
    end
  end

  describe "build_listing" do

    it "should return a SlashdotListing object" do
      fake_json = {}
      expect(@small_slashdot.build_listing(fake_json)).to be_an_instance_of(SlashdotListing)
    end

  end

  describe "build_all_listings" do

    it "should be an array of Listing objects" do
      expect(@big_slashdot.build_all_listings).to be_an_instance_of(Array)
    end

    it "should have instance elements of SlashdotListing" do
      expect(@big_slashdot.build_all_listings.first).to be_an_instance_of(SlashdotListing)
    end

  end

end

describe "Listing" do

  before(:all) do

    VCR.use_cassette("one_result_each", :record => :new_episodes) do
      @one_result_each = DiscussItApi.new('http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/', '3')
    end

    @reddit_listing   = @one_result_each.all_listings.reddit.first
    @hn_listing       = @one_result_each.all_listings.hn.first
    @slashdot_listing = @one_result_each.all_listings.slashdot.first

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
      expect(@slashdot_listing.score).to eq(30)
    end

  end

end

describe "ListingCollection" do

  before(:all) do

    VCR.use_cassette("one_result_each", :record => :new_episodes) do
      @one_result_each = DiscussItApi.new('http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/', '3')
    end

    @reddit_listings   = @one_result_each.all_listings.reddit
    @hn_listings       = @one_result_each.all_listings.hn
    @slashdot_listings = @one_result_each.all_listings.slashdot

  end

  describe "initialization" do

    it "should initialize as all_listings on DiscussItApi" do
      expect(@one_result_each.all_listings).to be_an_instance_of(ListingCollection)
    end

  end

  describe "accessors" do

    it "should return only HnListings from hn method" do
      expect(@hn_listings.all?{|listing| listing.is_a?(HnListing) } ).to be_true
    end

    it "should return only RedditListings from reddit method" do
      expect(@reddit_listings.all?{|listing| listing.is_a?(RedditListing) }).to be_true
    end

    it "should return only SlashdotListings from slashdot method" do
      expect(@slashdot_listings.all?{|listing| listing.is_a?(SlashdotListing) }).to be_true
    end

  end

  describe "tops" do

    it "should return 1 top listings for reddit" do
      expect(@one_result_each.all_listings.tops[:reddit]).to be_an_instance_of(RedditListing)
    end

    it "should return 1 top listings for hn" do
      expect(@one_result_each.all_listings.tops[:hn]).to be_an_instance_of(HnListing)
    end

    it "should return 1 top listings for slashdot" do
      expect(@one_result_each.all_listings.tops[:slashdot]).to be_an_instance_of(SlashdotListing)
    end

  end

end

describe "DiscussItApi" do

  before(:all) do

    VCR.use_cassette("one_result_each", :record => :new_episodes) do
      @one_result_each = DiscussItApi.new('http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/', '3')
    end

    VCR.use_cassette("many_results_reddit", :record => :new_episodes) do
      @many_results_reddit = DiscussItApi.new('restorethefourth.net', '2')
    end

    VCR.use_cassette("one_result_hn_reddit", :record => :new_episodes) do
      @one_result_hn_reddit = DiscussItApi.new('http://yorickpeterse.com/articles/debugging-with-pry/', '3')
    end

    VCR.use_cassette("many_results_hn_reddit", :record => :new_episodes) do
      @many_results_hn_reddit = DiscussItApi.new('http://www.ministryoftruth.me.uk/2013/07/24/cameron-porn-advisors-website-hacked-threatenslibels-blogger/', '2')
    end

  end

  describe "initialization", :vcr do

    it "should not initialize without an argument" do
      expect{ DiscussItApi.new() }.to_not be_an_instance_of(DiscussItApi)
    end

    it "should initialize with 1 arg" do
      expect(DiscussItApi.new("http://restorethefourth.net/", '2')).to be_an_instance_of(DiscussItApi)
    end

    it "should initialize with 2 args if 2nd is 2 or 3" do
      expect {
        DiscussItApi.new('http://example.com','http://example.org')
      }.not_to raise_error(ArgumentError)
    end

    it "should not break if initialized with 2 args if 2nd is not 2 or 3" do
      expect {
        DiscussItApi.new('http://example.com','5')
      }.not_to raise_error(ArgumentError)
    end

    it "should not initialize with 3 args" do
      expect {
        DiscussItApi.new('http://example.com','http://example.org','http://example.org')
      }.to raise_error(ArgumentError, "wrong number of arguments (3 for 2)")
    end

  end

  describe "find_all", :vcr do

    it "should return 4 results for multisite small listing" do
      expect(@one_result_each.find_all.all.length).to eq(4)
    end

    it "should return 28 results for singlesite large listing" do
      expect(@many_results_reddit.find_all.all.length).to eq(28)
    end

    it "should return 2 results for dualsite small listing" do
      expect(@one_result_hn_reddit.find_all.all.length).to eq(2)
    end

    it "should return 14 results for dualsite large listing" do
      expect(@many_results_hn_reddit.find_all.all.length).to eq(14)
    end

  end

  describe "find_top" do

    it "should return 3 results for multisite small listing" do
      # FIXME: this test sucks
      expect(@one_result_each.find_top.keys.length).to eq(3)
    end

    it "should return 1 results for singlesite large listing" do
      expect(@many_results_reddit.find_top.keys.length).to eq(1)
    end

    it "should return 2 results for dualsite small listing" do
      expect(@one_result_hn_reddit.find_top.keys.length).to eq(2)
    end

    it "should return 2 results for dualsite large listing" do
      expect(@many_results_hn_reddit.find_top.keys.length).to eq(2)
    end

  end

end
