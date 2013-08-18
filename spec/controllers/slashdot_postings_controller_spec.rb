require 'spec_helper'

describe SlashdotPostingsController do

  # This should return the minimal set of attributes required to create a valid
  # SlashdotPosting. As you add validations to SlashdotPosting, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "permalink" => "http://example.com" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SlashdotPostingsController. Be sure to keep this updated too.
  let(:valid_session) { {} }



  describe "POST find_by_url" do

    it "returns http success" do
      get 'find_by_url'
      expect(response).to be_success
    end

    it "returns empty array without param url" do
      # post :find_by_url
      # expect(response.body).to eq("[]")
    end

  end

#---------------------------------------------------------------------
# autogen tests
#---------------------------------------------------------------------

  describe "POST create" do

    describe "with valid params" do

      it "creates a new SlashdotPosting" do
        # expect {
        #   post :create, {:slashdot_posting => valid_attributes}, valid_session
        # }.to change(SlashdotPosting, :count).by(1)
      end

      it "assigns a newly created slashdot_posting as @slashdot_posting" do
        # post :create, {:slashdot_posting => valid_attributes}, valid_session
        # assigns(:slashdot_posting).should be_a(SlashdotPosting)
        # assigns(:slashdot_posting).should be_persisted
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested slashdot_posting" do
      # slashdot_posting = SlashdotPosting.create! valid_attributes
      # expect {
      #   delete :destroy, {:id => slashdot_posting.to_param}, valid_session
      # }.to change(SlashdotPosting, :count).by(-1)
    end

    it "redirects to the slashdot_postings list" do
      # slashdot_posting = SlashdotPosting.create! valid_attributes
      # delete :destroy, {:id => slashdot_posting.to_param}, valid_session
      # response.should redirect_to(slashdot_postings_url)
    end

  end

end
