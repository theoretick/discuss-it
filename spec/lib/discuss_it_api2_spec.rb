require 'spec_helper'
require 'discuss_it_api2'

describe "DiscussItApi" do

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

    MOCK_HN_RESPONSE = {"hits"=>5544612, "facet_results"=>{"fields"=>{}, "queries"=>{}}, "warnings"=>[], "request"=>{"facet"=>{"fields"=>{}, "queries"=>[]}, "stats"=>{}, "match_stopwords"=>false, "q"=>"", "start"=>0, "limit"=>10, "sortby"=>"score desc", "highlight"=>{"include_matches"=>false, "fragments"=>{"maxchars"=>100, "include"=>false, "markup_text"=>false}, "markup_items"=>false}, "weights"=>{"username"=>1.0, "parent_sigid"=>1.0, "domain"=>1.0, "title"=>1.0, "url"=>1.0, "text"=>1.0, "discussion.sigid"=>1.0, "type"=>1.0}, "filter"=>{"fields"=>{}, "queries"=>[]}, "boosts"=>{"fields"=>{}, "functions"=>{}, "filters"=>{}}}, "results"=>[{"item"=>{"username"=>"tokenadult", "parent_sigid"=>"1058559-e4031", "domain"=>nil, "title"=>nil, "url"=>nil, "text"=>"<i>It used to be that the FBI keeping a file open on somebody famous was considered scandal-worthy. Now FaceBook keeps much more personal information on all of us and people don't bat an eye about it.</i><p>That's a really good observation. People who are below a certain age don't have much perspective on<p>a) how mundane most information in FBI files always has been,<p>and<p>b) how much more pervasively personal information about most people is now shared by computerized networks than it was shared by small town gossip.", "discussion"=>{"title"=>"Chess grandmasters: Intelligent machines are about to revolutionize the world", "id"=>1058450, "sigid"=>"1058450-0a5e7"}, "id"=>1058579, "parent_id"=>1058559, "points"=>11, "create_ts"=>"2010-01-17T16:40:54Z", "num_comments"=>1, "cache_ts"=>"2011-01-04T17:38:43Z", "_id"=>"1058579-5530a", "type"=>"comment", "_noindex"=>false, "_update_ts"=>1307473725994030}, "score"=>1.0}, {"item"=>{"username"=>"blahedo", "parent_sigid"=>"1059214-3e932", "domain"=>nil, "title"=>nil, "url"=>nil, "text"=>"The linked page <i>explicitly</i> asks you to link to the top level: \"Do your friends a favor. Link to the front page  instead. Thanks!\"  Which makes more sense anyway.  So:<p><a href=\"http://code.google.com/p/vimcolorschemetest/\" rel=\"nofollow\">http://code.google.com/p/vimcolorschemetest/</a>", "discussion"=>{"title"=>"Vim Color Scheme Test", "id"=>1059214, "sigid"=>"1059214-3e932"}, "id"=>1059221, "parent_id"=>1059214, "points"=>6, "create_ts"=>"2010-01-18T01:17:34Z", "num_comments"=>1, "cache_ts"=>"2011-01-04T17:38:43Z", "_id"=>"1059221-80cee", "type"=>"comment", "_noindex"=>false, "_update_ts"=>1307473735075540}, "score"=>1.0}, {"item"=>{"username"=>"paulbaumgart", "parent_sigid"=>"1059089-ba6a6", "domain"=>nil, "title"=>nil, "url"=>nil, "text"=>"thanks :-)<p>I told you I spend too much time here :-P", "discussion"=>{"title"=>"Co-founder Google Doc - stage 2 (a semantic wiki)", "id"=>1058824, "sigid"=>"1058824-b3d7d"}, "id"=>1059157, "parent_id"=>1059089, "points"=>1, "create_ts"=>"2010-01-18T00:06:00Z", "num_comments"=>0, "cache_ts"=>"2011-01-04T17:38:43Z", "_id"=>"1059157-ee7a4", "type"=>"comment", "_noindex"=>false, "_update_ts"=>1307473735075540}, "score"=>1.0}, {"item"=>{"username"=>"nfnaaron", "parent_sigid"=>"1058507-71566", "domain"=>nil, "title"=>nil, "url"=>nil, "text"=>"I don't think advertising for \"a paper\" will ever be as lucrative as the old paper days, because it's too easy to drift over to the billion other sites on the web.<p>The old paper days allowed for virtual monopolies because it was physically inconvenient to have more than three or four papers at hand, and most people only had one. It was easier to convince an advertiser that a reader was going to at least glance through every section and be exposed to the ads.<p>These days I never read a news outlet's site all the way through[1], not in the way I used to sit on the floor on Sunday with paper and coffee. A news outlet has at most two or three articles' chance at getting my eyes to glide over an advertisement. I will never see 99% of what's on a site before I move on to some other site. Google is the only one making money this way.<p>[1] Except for Hacker News. I think aggregation points the way to where the money is in the future, both aggregation of content and aggregation of ads.", "discussion"=>{"title"=>"New York Times Ready to Charge Online Readers", "id"=>1058507, "sigid"=>"1058507-71566"}, "id"=>1059255, "parent_id"=>1058507, "points"=>1, "create_ts"=>"2010-01-18T01:50:40Z", "num_comments"=>0, "cache_ts"=>"2011-01-04T17:38:43Z", "_id"=>"1059255-3c708", "type"=>"comment", "_noindex"=>false, "_update_ts"=>1307473735075540}, "score"=>1.0}, {"item"=>{"username"=>"ubernostrum", "parent_sigid"=>"1058270-6c5bd", "domain"=>nil, "title"=>nil, "url"=>nil, "text"=>"Yeah, and most projects do -- it's called a style guide.", "discussion"=>{"title"=>"Why I love having tabs in source code.", "id"=>1058196, "sigid"=>"1058196-0bacc"}, "id"=>1059127, "parent_id"=>1058270, "points"=>1, "create_ts"=>"2010-01-17T23:35:16Z", "num_comments"=>0, "cache_ts"=>"2011-01-04T17:38:43Z", "_id"=>"1059127-5bf90", "type"=>"comment", "_noindex"=>false, "_update_ts"=>1307473735075540}, "score"=>1.0}, {"item"=>{"username"=>"voxcogitatio", "parent_sigid"=>nil, "domain"=>"git.kernel.org", "title"=>"Git Docs: It is a bold start", "url"=>"http://git.kernel.org/?p=git/git.git;a=blob;f=Documentation/technical/pack-heuristics.txt;h=103eb5d989349c8e7e0147920b2e218caba9daf9;hb=HEAD;resub=ofcourse#l27", "text"=>nil, "discussion"=>nil, "id"=>1058849, "parent_id"=>nil, "points"=>3, "create_ts"=>"2010-01-17T20:05:24Z", "num_comments"=>1, "cache_ts"=>"2011-01-04T17:38:43Z", "_id"=>"1058849-8b438", "type"=>"submission", "_noindex"=>false, "_update_ts"=>1307473725994030}, "score"=>1.0}, {"item"=>{"username"=>"ehsanul", "parent_sigid"=>"1058946-b1e4f", "domain"=>nil, "title"=>nil, "url"=>nil, "text"=>"I didn't even notice my terminal font until it being pointed out. So am I the only one perfectly happy with just Monospace?", "discussion"=>{"title"=>"Top Programming Fonts", "id"=>1058946, "sigid"=>"1058946-b1e4f"}, "id"=>1059300, "parent_id"=>1058946, "points"=>4, "create_ts"=>"2010-01-18T02:22:21Z", "num_comments"=>3, "cache_ts"=>"2011-01-04T17:38:43Z", "_id"=>"1059300-c27c3", "type"=>"comment", "_noindex"=>false, "_update_ts"=>1307473735075540}, "score"=>1.0}, {"item"=>{"username"=>"coffeemug", "parent_sigid"=>"1058359-04bcb", "domain"=>nil, "title"=>nil, "url"=>nil, "text"=>"I found that the best way for me to internalize a particular subject in hard science is to follow its history by reading the original papers. It's a hard way to do it, but it helps you understand the motivation, the progression of ideas, and the rigor that went into it. Anything else doesn't quite work for me - I feel like I \"sort of\" understand, but five minutes after I close the textbook (or the YouTube video) the understanding goes away with it.<p>I watched some of these lectures - they're excellent, but a bit too hand-wavy. Without getting through the rigor there's no hope to gain a complete understanding of the subject matter that stays with you forever.", "discussion"=>{"title"=>"Need to refresh your math skills? From basic algebra to calculus and beyond.", "id"=>1058359, "sigid"=>"1058359-04bcb"}, "id"=>1058467, "parent_id"=>1058359, "points"=>4, "create_ts"=>"2010-01-17T14:37:39Z", "num_comments"=>11, "cache_ts"=>"2011-01-04T17:38:43Z", "_id"=>"1058467-74a91", "type"=>"comment", "_noindex"=>false, "_update_ts"=>1307473725994030}, "score"=>1.0}, {"item"=>{"username"=>"og1", "parent_sigid"=>"1059123-eadcf", "domain"=>nil, "title"=>nil, "url"=>nil, "text"=>"I agree, 89 is my favorite as well.", "discussion"=>{"title"=>"Ask HN: Help me pick a logo for my web app, Preceden", "id"=>1059075, "sigid"=>"1059075-3afb2"}, "id"=>1059263, "parent_id"=>1059123, "points"=>1, "create_ts"=>"2010-01-18T01:55:19Z", "num_comments"=>3, "cache_ts"=>"2011-01-04T17:38:43Z", "_id"=>"1059263-8218d", "type"=>"comment", "_noindex"=>false, "_update_ts"=>1307473735075540}, "score"=>1.0}, {"item"=>{"username"=>"lefstathiou", "parent_sigid"=>nil, "domain"=>nil, "title"=>"Ask HN: Anyone have a good accountant?", "url"=>nil, "text"=>"Hey All,<p>Tax season is coming up and my partner and I are getting to the point that we need to find someone legit to do our taxes. We have two startups and have worked with many freelancers so we have a ton of questions. Does anyone have anyone they would recommend, preferably in the New York area? I dont know if you need an accountant to be in the same state, but we are technically a New Jersey company.<p>Thanks. I prefer you post in case this post can help anyone else, otherwise feel free to reach out to me directly.<p>Leo Efstathiou | leo@groupie.mobi | 404-368-5160", "discussion"=>nil, "id"=>1059247, "parent_id"=>nil, "points"=>2, "create_ts"=>"2010-01-18T01:41:29Z", "num_comments"=>0, "cache_ts"=>"2011-01-04T17:38:43Z", "_id"=>"1059247-68a4d", "type"=>"submission", "_noindex"=>false, "_update_ts"=>1307473735075540}, "score"=>1.0}], "time"=>0.11842703819274902}

    it "should return ruby hash from reddit string", :vcr do
      expect(Fetch.get_response('http://www.reddit.com/api/info.json?url=restorethefourth.net')).to be_an_instance_of(Hash)
    end

    it "should not return ruby hash from a nil reddit string", :vcr do
      expect(Fetch.get_response('http://www.reddit.com/api/info.json?url=')).to eq({"kind"=>"Listing", "data"=>{"modhash"=>"", "children"=>[], "after"=>nil, "before"=>nil}})
    end

    it "should return ruby hash from hn string", :vcr do
      expect(Fetch.get_response('http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]=restorethefourth.net')).to be_an_instance_of(Hash)
    end

    # it "should return ruby hash from a nil hn string", :vcr do
    #   expect(Fetch.get_response('http://api.thriftdb.com/api.hnsearch.com/items/_search?filter[fields][url]=')).to eq(MOCK_HN_RESPONSE)
    # end

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
    @std_mock_hash = {
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
    it "should not init with 0 arg"
    it "should not init with 1+ args"
  end

  describe "pull_out" do

    it "should return [data][children] from parent hash" do
      expect(@reddit_fetch.pull_out(@raw_mock_hash)).to eq(@raw_mock_hash["data"]["children"])
    end
  end

  describe "standardize" do

    it "should change hash key 'permalink' to 'location'" do
      expect(@reddit_fetch.standardize(@raw_mock_hash)).to eq(@std_mock_hash)
    end

    it "should not change hash key 'score'" do
      expect(@reddit_fetch.standardize(@raw_mock_hash)).to eq(@std_mock_hash)
    end

    it "should not change hash key 'foo'" do
      expect(@reddit_fetch.standardize(@raw_mock_hash)).to eq(@std_mock_hash)
    end
  end

  # describe "build_listing" do

  #   it "should return a listing object" do
  #   end
  # end

#   describe "build_all_listings" do

#     it "should return an array of listing objects" do
#     end
#   end

# end

# describe "HnFetch" do
# end

# describe "Listing" do

end
