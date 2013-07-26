require 'spec_helper'

describe "slashdot_postings/edit" do
  before(:each) do
    @slashdot_posting = assign(:slashdot_posting, stub_model(SlashdotPosting,
      :title => "MyString",
      :permalink => "MyString",
      :urls => "MyText"
    ))
  end

  it "renders the edit slashdot_posting form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", slashdot_posting_path(@slashdot_posting), "post" do
      assert_select "input#slashdot_posting_title[name=?]", "slashdot_posting[title]"
      assert_select "input#slashdot_posting_permalink[name=?]", "slashdot_posting[permalink]"
      assert_select "textarea#slashdot_posting_urls[name=?]", "slashdot_posting[urls]"
    end
  end
end
