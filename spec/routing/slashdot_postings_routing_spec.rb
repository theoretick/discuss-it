require "spec_helper"

describe SlashdotPostingsController do
  describe "routing" do

    it "routes to #index" do
      get("/slashdot_postings").should route_to("slashdot_postings#index")
    end

    it "routes to #new" do
      get("/slashdot_postings/new").should route_to("slashdot_postings#new")
    end

    it "routes to #show" do
      get("/slashdot_postings/1").should route_to("slashdot_postings#show", :id => "1")
    end

    it "routes to #edit" do
      get("/slashdot_postings/1/edit").should route_to("slashdot_postings#edit", :id => "1")
    end

    it "routes to #create" do
      post("/slashdot_postings").should route_to("slashdot_postings#create")
    end

    it "routes to #update" do
      put("/slashdot_postings/1").should route_to("slashdot_postings#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/slashdot_postings/1").should route_to("slashdot_postings#destroy", :id => "1")
    end

  end
end
