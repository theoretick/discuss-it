require 'spec_helper'

describe "SlashdotPostings" do

  describe "GET slashdot_postings" do

    it "returns proper JSON response" do

      visit '/'
      fill_in "query", :with => 'http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/'
      click_button '(Beta) Search'
      slashdot_postings = JSON.parse(response.body)
      expect(SlashdotPosting.where("id"=>2862).first.permalink).to eq(slashdot_postings.first["permalink"])
    end

    # THIS LINK IS WHAT I WANT
    #  http://localhost:5100/slashdot_postings/search?url=http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/

  end

end