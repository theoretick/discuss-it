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

  describe "GET index" do
     it "assigns all slashdot_postings as @slashdot_postings" #do
  #     slashdot_posting = SlashdotPosting.create! valid_attributes
  #     get :index, {}, valid_session
  #     assigns(:slashdot_postings).should eq([slashdot_posting])
  #   end
  end

  describe "GET show" do
    it "assigns the requested slashdot_posting as @slashdot_posting" #do
  #     slashdot_posting = SlashdotPosting.create! valid_attributes
  #     get :show, {:id => slashdot_posting.to_param}, valid_session
  #     assigns(:slashdot_posting).should eq(slashdot_posting)
  #   end
  end

  describe "GET new" do
    it "assigns a new slashdot_posting as @slashdot_posting" #do
  #     get :new, {}, valid_session
  #     assigns(:slashdot_posting).should be_a_new(SlashdotPosting)
  #   end
  end

  describe "GET edit" do
    it "assigns the requested slashdot_posting as @slashdot_posting" #do
  #     slashdot_posting = SlashdotPosting.create! valid_attributes
  #     get :edit, {:id => slashdot_posting.to_param}, valid_session
  #     assigns(:slashdot_posting).should eq(slashdot_posting)
  #   end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new SlashdotPosting" #do
  #       expect {
  #         post :create, {:slashdot_posting => valid_attributes}, valid_session
  #       }.to change(SlashdotPosting, :count).by(1)
  #     end

      it "assigns a newly created slashdot_posting as @slashdot_posting" #do
  #       post :create, {:slashdot_posting => valid_attributes}, valid_session
  #       assigns(:slashdot_posting).should be_a(SlashdotPosting)
  #       assigns(:slashdot_posting).should be_persisted
  #     end

      it "redirects to the created slashdot_posting" #do
  #       post :create, {:slashdot_posting => valid_attributes}, valid_session
  #       response.should redirect_to(SlashdotPosting.last)
  #     end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved slashdot_posting as @slashdot_posting" #do
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       SlashdotPosting.any_instance.stub(:save).and_return(false)
  #       post :create, {:slashdot_posting => { "title" => "invalid value" }}, valid_session
  #       assigns(:slashdot_posting).should be_a_new(SlashdotPosting)
      # end

      it "re-renders the 'new' template" #do
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       SlashdotPosting.any_instance.stub(:save).and_return(false)
  #       post :create, {:slashdot_posting => { "title" => "invalid value" }}, valid_session
  #       response.should render_template("new")
      # end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested slashdot_posting" #do
  #       slashdot_posting = SlashdotPosting.create! valid_attributes
  #       # Assuming there are no other slashdot_postings in the database, this
  #       # specifies that the SlashdotPosting created on the previous line
  #       # receives the :update_attributes message with whatever params are
  #       # submitted in the request.
  #       SlashdotPosting.any_instance.should_receive(:update).with({ "title" => "MyString" })
  #       put :update, {:id => slashdot_posting.to_param, :slashdot_posting => { "title" => "MyString" }}, valid_session
  #     end

      it "assigns the requested slashdot_posting as @slashdot_posting" #do
  #       slashdot_posting = SlashdotPosting.create! valid_attributes
  #       put :update, {:id => slashdot_posting.to_param, :slashdot_posting => valid_attributes}, valid_session
  #       assigns(:slashdot_posting).should eq(slashdot_posting)
  #     end

      it "redirects to the slashdot_posting" #do
  #       slashdot_posting = SlashdotPosting.create! valid_attributes
  #       put :update, {:id => slashdot_posting.to_param, :slashdot_posting => valid_attributes}, valid_session
  #       response.should redirect_to(slashdot_posting)
  #     end
    end

    describe "with invalid params" do
      it "assigns the slashdot_posting as @slashdot_posting" #do
  #       slashdot_posting = SlashdotPosting.create! valid_attributes
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       SlashdotPosting.any_instance.stub(:save).and_return(false)
  #       put :update, {:id => slashdot_posting.to_param, :slashdot_posting => { "title" => "invalid value" }}, valid_session
  #       assigns(:slashdot_posting).should eq(slashdot_posting)
  #     end

      it "re-renders the 'edit' template" #do
  #       slashdot_posting = SlashdotPosting.create! valid_attributes
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       SlashdotPosting.any_instance.stub(:save).and_return(false)
  #       put :update, {:id => slashdot_posting.to_param, :slashdot_posting => { "title" => "invalid value" }}, valid_session
  #       response.should render_template("edit")
  #     end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested slashdot_posting" do
      slashdot_posting = SlashdotPosting.create! valid_attributes
      expect {
        delete :destroy, {:id => slashdot_posting.to_param}, valid_session
      }.to change(SlashdotPosting, :count).by(-1)
    end

    it "redirects to the slashdot_postings list" do
      slashdot_posting = SlashdotPosting.create! valid_attributes
      delete :destroy, {:id => slashdot_posting.to_param}, valid_session
      response.should redirect_to(slashdot_postings_url)
    end
  end

end
