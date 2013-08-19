require 'spec_helper'

describe "searches/edit" do
  before(:each) do
    @search = assign(:search, stub_model(Search,
      :query_url => "MyText",
      :user => nil
    ))
  end

  it "renders the edit search form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", search_path(@search), "post" do
      assert_select "textarea#search_query_url[name=?]", "search[query_url]"
      assert_select "input#search_user[name=?]", "search[user]"
    end
  end
end
