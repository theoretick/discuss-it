require 'spec_helper'

describe "slashdot_postings/new" do
  before(:each) do
    assign(:slashdot_posting, stub_model(SlashdotPosting,
      :title => "MyString",
      :permalink => "MyString",
      :urls => "MyText"
    ).as_new_record)
  end

  it "renders new slashdot_posting form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", slashdot_postings_path, "post" do
      assert_select "input#slashdot_posting_title[name=?]", "slashdot_posting[title]"
      assert_select "input#slashdot_posting_permalink[name=?]", "slashdot_posting[permalink]"
      assert_select "textarea#slashdot_posting_urls[name=?]", "slashdot_posting[urls]"
    end
  end
end
