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

    it "should have a location accessor" do
      one_result = DiscussItApi.new('yorickpeterse.com/articles/debugging-with-pry/')
      expect(one_result.all_listings.reddit.first.location).to eq('http://www.reddit.com/r/ruby/comments/mqtwx/debugging_with_pry/')
    end

  end

  describe "find_all", :vcr do

    it "should return 2 results" do
      one_result = (DiscussItApi.new('yorickpeterse.com/articles/debugging-with-pry/'))
      expect(one_result.find_all.all.length).to eq(2)
    end

  end

  describe "find_top", :vcr do

    it "should return 2 results" do
      @one_result = DiscussItApi.new('yorickpeterse.com/articles/debugging-with-pry/')
      # FIXME: this test sucks
      expect(@one_result.find_top.keys.length).to eq(2)
    end
  end

end

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

  describe "get_response" do

    before(:all) do
      @api_url = 'http://www.reddit.com/api/info.json?url='
    end

    it "should return ruby hash from reddit string", :vcr do
      expect(Fetch.get_response(@api_url, 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    it "should not return ruby hash from a nil reddit string", :vcr do
      expect(Fetch.get_response(@api_url, '')).to eq({"kind"=>"Listing", "data"=>{"modhash"=>"", "children"=>[], "after"=>nil, "before"=>nil}})
    end

    it "should return ruby hash from hn string", :vcr do
      expect(Fetch.get_response(@api_url, 'restorethefourth.net')).to be_an_instance_of(Hash)
    end

    # FIXME: make this test better, it currently checks length, is invalidated by time marker on api response
    it "should return ruby hash from a nil hn string"

  end
end

describe "RedditFetch" do

  before(:all) do

    VCR.use_cassette("should_init_with_1_arg", :record => :new_episodes) do
      @big_reddit_fetch = RedditFetch.new("restorethefourth.net")
    end

    VCR.use_cassette("pull_out_and_standardize", :record => :new_episodes) do
      @one_result_per_reddit = RedditFetch.new("yorickpeterse.com/articles/debugging-with-pry/")
    end

  end

  describe "initialize" do

    it "should init with 1 arg" do
      expect(@big_reddit_fetch).to be_an_instance_of(RedditFetch)
    end

    it "should not init with 0 arg" do
      expect{ RedditFetch.new() }.not_to be_an_instance_of(RedditFetch)
    end

    it "should not init with 1+ args" do
      expect{ RedditFetch.new("restorethefourth.net", "example.com") }.not_to be_an_instance_of(RedditFetch)
    end
  end

  describe "pull_out" do

    before(:each) do
      @raw_mock_hash = {
        "kind" => "Listing",
        "data" => {
           "modhash" => "",
          "children" => [
                {
              "kind" => "t3",
              "data" => {
                            "domain" => "yorickpeterse.com",
                         "banned_by" => nil,
                       "media_embed" => {},
                         "subreddit" => "ruby",
                     "selftext_html" => nil,
                          "selftext" => "",
                             "likes" => nil,
                   "link_flair_text" => nil,
                                "id" => "mqtwx",
                           "clicked" => false,
                             "title" => "Debugging With Pry",
                             "media" => nil,
                             "score" => 17,
                       "approved_by" => nil,
                           "over_18" => false,
                            "hidden" => false,
                         "thumbnail" => "",
                      "subreddit_id" => "t5_2qh21",
                            "edited" => false,
              "link_flair_css_class" => nil,
            "author_flair_css_class" => nil,
                             "downs" => 4,
                             "saved" => false,
                           "is_self" => false,
                         "permalink" => "/r/ruby/comments/mqtwx/debugging_with_pry/",
                              "name" => "t3_mqtwx",
                           "created" => 1322400028.0,
      "url" => "http://yorickpeterse.com/articles/debugging-with-pry/",
                 "author_flair_text" => nil,
                            "author" => "yorickpeterse",
                       "created_utc" => 1322400028.0,
                               "ups" => 21,
                      "num_comments" => 0,
                       "num_reports" => nil,
                     "distinguished" => nil
              }
            }
          ]
        }
      }
    end

    it "should return [data][children] from parent hash"

  end

#   describe "standardize" do

#     it "should change hash key 'permalink' to 'location'" do
#       expect(@reddit_fetch.standardize(@raw_mock_hash)).to eq(@standardized_mock_hash)
#     end

#     it "should not change hash key 'score'" do
#       expect(@reddit_fetch.standardize(@raw_mock_hash)).to eq(@standardized_mock_hash)
#     end

#     it "should not change hash key 'foo'" do
#       expect(@reddit_fetch.standardize(@raw_mock_hash)).to eq(@standardized_mock_hash)
#     end

#   end

  # describe "build_listing" do

  #   it "should return a Listing object"
  # end

  # describe "build_all_listings" do

  #   it "should return an array of Listing objects"
  # end

# end

# describe "HnFetch" do

#   before(:all) do
#     @raw_mock_hash = {
#       "foo" => "stringy",
#       "id" => "beer",
#       "points" => 7,
#       "data" => {
#         "children" => ['b', 'a', 'r']
#         }
#       }
#     @standardized_mock_hash = {
#       "foo" => "stringy",
#       "location" => "beer",
#       "score" => 7,
#       "data" => {
#         "children" => ['b', 'a', 'r']
#         }
#       }

#     VCR.use_cassette("hn should init with 1 arg", :record => :new_episodes) do
#       @hn_fetch = HnFetch.new("restorethefourth.net")
#     end
#   end

#   describe "initialize" do

#     it "should init with 1 arg" do
#       expect(@hn_fetch).to be_an_instance_of(HnFetch)
#     end

#     it "should not init with 0 arg" do
#       expect{ HnFetch.new() }.not_to be_an_instance_of(HnFetch)
#     end

#     it "should not init with 1+ args" do
#       expect{ HnFetch.new("restorethefourth.net", "example.com") }.not_to be_an_instance_of(HnFetch)
#     end
#   end

#   describe "pull_out" do

#     it "should return [results] from parent hash" do
#       expect(@hn_fetch.pull_out(@raw_mock_hash)).to eq(@raw_mock_hash["results"])
#     end
#   end

#   describe "standardize" do

#     it "should change hash key 'permalink' to 'location'" do
#       expect(@hn_fetch.standardize(@raw_mock_hash)).to eq(@standardized_mock_hash)
#     end

#     it "should not change hash key 'score'" do
#       expect(@hn_fetch.standardize(@raw_mock_hash)).to eq(@standardized_mock_hash)
#     end

#     it "should not change hash key 'foo'" do
#       expect(@hn_fetch.standardize(@raw_mock_hash)).to eq(@standardized_mock_hash)
#     end

#   end

#   describe "build_listing" do

#     TEST_IN_HASH = {"item"=>
#       {"username"=>"YorickPeterse",
#        "parent_sigid"=>nil,
#        "domain"=>"yorickpeterse.com",
#        "title"=>"Debugging With Pry",
#        "url"=>"http://yorickpeterse.com/articles/debugging-with-pry/",
#        "text"=>nil,
#        "discussion"=>nil,
#        "id"=>3282367,
#        "parent_id"=>nil,
#        "points"=>2,
#        "create_ts"=>"2011-11-27T13:18:01Z",
#        "num_comments"=>0,
#        "cache_ts"=>"2011-12-15T06:31:59Z",
#        "_id"=>"3282367-595b6",
#        "type"=>"submission",
#        "_noindex"=>false,
#        "_update_ts"=>1323930764688130},
#        "score"=>1.0}

#     TEST_LISTING = {"username"=>"YorickPeterse",
#       "parent_sigid"=>nil,
#       "domain"=>"yorickpeterse.com",
#       "title"=>"Debugging With Pry",
#       "url"=>"http://yorickpeterse.com/articles/debugging-with-pry/",
#       "text"=>nil,
#       "discussion"=>nil,
#       "location"=>3282367,
#       "parent_id"=>nil,
#       "score"=>2,
#       "create_ts"=>"2011-11-27T13:18:01Z",
#       "num_comments"=>0,
#       "cache_ts"=>"2011-12-15T06:31:59Z",
#       "_id"=>"3282367-595b6",
#       "type"=>"submission",
#       "_noindex"=>false,
#       "_update_ts"=>1323930764688130}

#     it "should return a Listing object" do
#       expect(@hn_fetch.build_listing(TEST_IN_HASH)).to be_an_instance_of(Listing)
#     end

#     it "Listing.new should return a Listing object" do
#       expect(Listing.new(TEST_LISTING)).to be_an_instance_of(Listing)
#     end

#     it "should not return a Listing object with no arg" do
#       expect{ @hn_fetch.build_listing() }.not_to be_an_instance_of(Listing)
#     end

#     it "should not return a Listing object with 1 + args" do
#       expect{ @hn_fetch.build_listing(1,2) }.not_to be_an_instance_of(Listing)
#     end

#   end

#   describe "build_all_listings", :vcr do

#     it "should return an array of Listing objects" do
#       expect(@hn_fetch.build_all_listings).to be_an_instance_of(Array)
#     end

#     it "should return an array of Listing objects" do
#       expect(@hn_fetch.build_all_listings.first).to be_an_instance_of(Listing)
#     end

#     # expect(@hn_fetch.build_all_listings).to contain(Listing)

#     it "should not return an array of Listing objects with no args"

#     it "should not return an array of Listing objects with no args"

#   end
end

describe "Listing" do

  it 'should have values accessible as keys'
  it 'should have values accessible as attributes'
  it 'should contain key "location"'
  it 'should contain key "score"'
  it 'should not contain key "permalink"'
  it 'should not be writeable'
end
