require 'spec_helper'

describe "slashdot_postings/index" do
  before(:each) do
    assign(:slashdot_postings, [
      stub_model(SlashdotPosting,
        :title => "Title",
        :permalink => "Permalink",
        :urls => "MyText"
      ),
      stub_model(SlashdotPosting,
        :title => "Title",
        :permalink => "Permalink",
        :urls => "MyText"
      )
    ])
  end

  it "renders a list of slashdot_postings" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Permalink".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
