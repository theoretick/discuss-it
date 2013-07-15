require 'spec_helper'

describe "static_pages/submit.html.erb" do

  it "should have an anchor tag 'a'" do
    visit '/'
    expect(page).to have_selector("a")
  end

  it "should have an anchor tag 'a'" do
    visit '/'
    expect(page).to have_selector("a")
  end

end

