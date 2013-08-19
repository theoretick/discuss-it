require 'spec_helper'

describe "searches/show" do
  before(:each) do
    @search = assign(:search, stub_model(Search,
      :query_url => "MyText",
      :user => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    rendered.should match(//)
  end
end
