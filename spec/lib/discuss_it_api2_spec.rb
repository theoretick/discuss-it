require 'spec_helper'
require 'discuss_it_api2'

describe "discuss it api 2" do

  # before(:all) do
  #   VCR.turn_off!
  #   @discussit = DiscussItApi.new("http://restorethefourth.net/")
  # end

  describe "initialization" do

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
