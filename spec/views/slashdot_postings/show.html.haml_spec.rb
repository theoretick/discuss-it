require 'spec_helper'

describe "slashdot_postings/show" do
  before(:each) do
    @slashdot_posting = assign(:slashdot_posting, stub_model(SlashdotPosting,
      :title => "Title",
      :permalink => "Permalink",
      :urls => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
    rendered.should match(/Permalink/)
    rendered.should match(/MyText/)
  end
end
