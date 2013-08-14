require 'spec_helper'

describe "DiscussIt" do

  describe "DiscussItApi" do

    before(:all) do

      VCR.use_cassette("one_result_each", :record => :new_episodes) do
        @one_result_each = DiscussIt::DiscussItApi.new('http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/', 3)
      end

      VCR.use_cassette("many_results_reddit", :record => :new_episodes) do
        @many_results_reddit = DiscussIt::DiscussItApi.new('restorethefourth.net', 2)
      end

      VCR.use_cassette("one_result_hn_reddit", :record => :new_episodes) do
        @one_result_hn_reddit = DiscussIt::DiscussItApi.new('http://yorickpeterse.com/articles/debugging-with-pry/', 3)
      end

      VCR.use_cassette("many_results_hn_reddit", :record => :new_episodes) do
        @many_results_hn_reddit = DiscussIt::DiscussItApi.new('http://www.ministryoftruth.me.uk/2013/07/24/cameron-porn-advisors-website-hacked-threatenslibels-blogger/', 2)
      end

    end

    # describe "initialization", :vcr do

    #   it "should not initialize without an argument" do
    #     expect{
    #         DiscussIt::DiscussItApi.new()
    #       }.to raise_error(ArgumentError)
    #   end

    #   it "should initialize without version arg" do
    #     expect(DiscussIt::DiscussItApi.new("http://restorethefourth.net/")).to be_an_instance_of(DiscussIt::DiscussItApi)
    #   end

    #   it "should initialize with version arg" do
    #     expect(DiscussIt::DiscussItApi.new("http://restorethefourth.net/", '2')).to be_an_instance_of(DiscussIt::DiscussItApi)
    #   end

    # end

    describe "find_all", :vcr do

      it "should return 4 results for multisite small listing" do
        expect(@one_result_each.find_all.all.length).to eq(4)
      end

      it "should return 29 results for singlesite large listing" do
        expect(@many_results_reddit.find_all.all.length).to eq(29)
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

      # TODO: add test for only slashdot

    end

  end

end