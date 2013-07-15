require 'spec_helper'
require 'discuss_it_api'

describe "discuss it api" do

  before(:each) do
    @discussit = DiscussItApi.new('http://jmoiron.net/blog/japanese-peer-peer/')
  end

  describe "initialization" do

    it "should not initialize without an argument" do
      expect{ DiscussItApi.new() }.to_not be_an_instance_of(DiscussItApi)
    end

    it "should initialize with 1 arg" do
      expect(@discussit).to be_an_instance_of(DiscussItApi)
    end

    it "should not initialize with 2 args" do
      expect {
        DiscussItApi.new('http://example.com','http://example.org')
      }.to raise_error(ArgumentError, "wrong number of arguments (2 for 1)")
    end
  end

  describe "get_json" do

    it "should raise error if given malformed URL" do
      expect {
        @discussit.get_json(
        'http://www.reddit.com/api/info.json?url=',
        '%')
      }.to raise_error(DiscussItUrlError)
    end

    # it "should return parsed JSON if given valid URL" do
    #   expect(@discussit.get_json('http://www.reddit.com/api/info.json?url=',
    #     'example.com')).to eq(MOCK_RESPONSE)
    # end

  end

  describe "format_url" do

    it "should add 'http://' if not provided" do
      expect(@discussit.format_url('example.com')).to eq('http://example.com/')
    end

    it "should add trailing '/' if not provided" do
      expect(@discussit.format_url('http://example.com')).to eq('http://example.com/')
    end

  end

  describe "parse_response" do

    it "should return nil if passed an empty list" do
      expect(@discussit.parse_response(:reddit,{})).to be_nil
    end

    # mocha this shit
    #
    # it "should get a correct substring from @discussit" do
    #   expect(@discussit.parse_response(:reddit,)).to eql(
    #     '/r/technology/comments/1hxl84/japans_anonymous_decentralized_p2p_networks_2008/')
    # end
  end

  describe "find_all" do

    it "should get back correct n-item array from find_all" do
      expect(@discussit.find_all).to eq(
        [
          'http://www.reddit.com/r/technology/comments/1hxl84/japans_anonymous_decentralized_p2p_networks_2008/',
          'http://news.ycombinator.com/item?id=6012405'
        ])
    end
  end

  describe "find_top" do

    it "should get back correct 2-item array from find_top" do
      expect(@discussit.find_top).to eq(
        [
          'http://www.reddit.com/r/technology/comments/1hxl84/japans_anonymous_decentralized_p2p_networks_2008/',
          'http://news.ycombinator.com/item?id=6012405'
        ])
    end
  end

end

