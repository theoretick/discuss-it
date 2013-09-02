require "spec_helper"

describe SearchesController do

  describe "GET /searches" do

    it "redirects to index and flashes if not signed in as Admin" do
      get searches_path
      response.status.should be(302)
    end

  end


end
