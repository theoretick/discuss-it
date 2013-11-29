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

    describe "#find_all", :vcr do

      it "returns at least one results for multisite small listing" do
        expect(@one_result_each.find_all.all.length).to have_at_least(1).things
      end

      it "returns at least one results for singlesite large listing" do
        expect(@many_results_reddit.find_all.all.length).to have_at_least(1).things
      end

      it "returns at least one results for dualsite small listing" do
        expect(@one_result_hn_reddit.find_all.all.length).to have_at_least(1).things
      end

      it "returns at least one results for dualsite large listing" do
        expect(@many_results_hn_reddit.find_all.all.length).to have_at_least(1).things
      end

    end

    describe "#find_top" do

      it "returns at least one results for multisite small listing" do
        expect(@one_result_each.find_top.length).to have_at_least(1).things
      end

      it "returns at least one results for singlesite large listing" do
        expect(@many_results_reddit.find_top.length).to have_at_least(1).things
      end

      it "returns at least one results for dualsite small listing" do
        expect(@one_result_hn_reddit.find_top.length).to have_at_least(1).things
      end

      it "returns at least one results for dualsite large listing" do
        expect(@many_results_hn_reddit.find_top.length).to have_at_least(1).things
      end

      # TODO: add test for only slashdot

    end

  end

end