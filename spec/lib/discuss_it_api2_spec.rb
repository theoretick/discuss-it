require 'spec_helper'
require 'discuss_it_api2'

describe "DiscussItApi" do

  # FIXME: before all doesn't work - chuck
  # before(:all) do
  #   VCR.use_cassette("should_init_with_1_arg", :record => :new_episodes) do
  #     @reddit_fetch = RedditFetch.new("restorethefourth.net")
  #   end
  # end

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

  describe "listing", :vcr do

    it "should have a location key" do
      @one_result = (DiscussItApi.new('yorickpeterse.com/articles/debugging-with-pry/'))
      expect(@one_result.reddit_listings.first.location).to eq('/r/ruby/comments/mqtwx/debugging_with_pry/')
    end

  end

  describe "find_all", :vcr do

    it "should return 3 results" do
      @one_result = (DiscussItApi.new('yorickpeterse.com/articles/debugging-with-pry/'))
      expect(@one_result.find_all.length).to eq(3)
    end

  end

  describe "find_top", :vcr do

    it "should return 2 results" do
      @one_result = DiscussItApi.new('yorickpeterse.com/articles/debugging-with-pry/')
      expect(@one_result.find_top.length).to eq(2)
    end
  end

end

describe "Fetch" do

  describe "http_add" do

    it "should add http if not found" do
      expect(Fetch.http_add('restorethefourth.net')).to eq('http://restorethefourth.net')
    end

    it "should not add http if found" do
      expect(Fetch.http_add('http://restorethefourth.net')).to eq('http://restorethefourth.net')
    end

  end

  describe "parse_json" do

    it "should return a ruby hash" do
      fake_json = {"name" => "discussit"}.to_json
      expect(Fetch.parse_json(fake_json)).to be_an_instance_of(Hash)
    end

  end

  describe "get_response" do

    MOCK_NIL_HN_RESPONSE = {"hits"=>0, "facet_results"=>{"fields"=>{}, "queries"=>{}}, "warnings"=>[], "request"=>{"facet"=>{"fields"=>{}, "queries"=>[]}, "stats"=>{}, "match_stopwords"=>false, "q"=>"", "start"=>0, "limit"=>10, "sortby"=>"score desc", "highlight"=>{"include_matches"=>false, "fragments"=>{"maxchars"=>100, "include"=>false, "markup_text"=>false}, "markup_items"=>false}, "weights"=>{"username"=>1.0, "parent_sigid"=>1.0, "domain"=>1.0, "title"=>1.0, "url"=>1.0, "text"=>1.0, "discussion.sigid"=>1.0, "type"=>1.0}, "filter"=>{"fields"=>{"url"=>["http://"]}, "queries"=>[]}, "boosts"=>{"fields"=>{}, "functions"=>{}, "filters"=>{}}}, "results"=>[], "time"=>0.005897998809814453}

    it "should return ruby hash from reddit string", :vcr do
      expect(Fetch.get_response('http://www.reddit.com/api/info.json?url=', 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    it "should not return ruby hash from a nil reddit string", :vcr do
      expect(Fetch.get_response('http://www.reddit.com/api/info.json?url=', '')).to eq({"kind"=>"Listing", "data"=>{"modhash"=>"", "children"=>[], "after"=>nil, "before"=>nil}})
    end

    it "should return ruby hash from hn string", :vcr do
      expect(Fetch.get_response('http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]=', 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    # FIXME: make this test better, it currently checks length, is invalidated by time marker on api response
    it "should return ruby hash from a nil hn string", :vcr do
      expect(Fetch.get_response('http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]=', '').length).to eq(MOCK_NIL_HN_RESPONSE.length)
    end

  end
end

describe "RedditFetch" do

  before(:all) do
    @raw_mock_hash = {
      "foo" => "stringy",
      "permalink" => "beer",
      "score" => 7,
      "data" => {
        "children" => ['b', 'a', 'r']
        }
      }
    @standardized_mock_hash = {
      "foo" => "stringy",
      "location" => "beer",
      "score" => 7,
      "data" => {
        "children" => ['b', 'a', 'r']
        }
      }

    VCR.use_cassette("should_init_with_1_arg", :record => :new_episodes) do
      @reddit_fetch = RedditFetch.new("restorethefourth.net")
    end

  end

  describe "initialize" do

    it "should init with 1 arg" do
      expect(@reddit_fetch).to be_an_instance_of(RedditFetch)
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
      expect(@reddit_fetch.pull_out(@raw_mock_hash)).to eq(@raw_mock_hash["data"]["children"])
    end
  end

  describe "standardize" do

    it "should change hash key 'permalink' to 'location'" do
      expect(@reddit_fetch.standardize(@raw_mock_hash)).to eq(@standardized_mock_hash)
    end

    it "should not change hash key 'score'" do
      expect(@reddit_fetch.standardize(@raw_mock_hash)).to eq(@standardized_mock_hash)
    end

    it "should not change hash key 'foo'" do
      expect(@reddit_fetch.standardize(@raw_mock_hash)).to eq(@standardized_mock_hash)
    end

  end

  describe "build_listing" do

    it "should return a Listing object"
  end

  describe "build_all_listings" do

    it "should return an array of Listing objects"
  end

end

describe "HnFetch" do


end

describe "Listing" do

  it 'should have values accessible as keys'
  it 'should have values accessible as attributes'
  it 'should contain key "location"'
  it 'should contain key "score"'
  it 'should not contain key "permalink"'
  it 'should not be writeable'
end
