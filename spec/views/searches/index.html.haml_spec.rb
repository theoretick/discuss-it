require 'spec_helper'

describe "searches/index" do
  before(:each) do
    assign(:searches, [
      stub_model(Search,
        :query_url => "MyText",
        :user => nil
      ),
      stub_model(Search,
        :query_url => "MyText",
        :user => nil
      )
    ])
  end

  it "renders a list of searches" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
