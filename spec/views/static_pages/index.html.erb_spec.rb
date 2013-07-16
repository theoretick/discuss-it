require 'spec_helper'

describe "static_pages/index.html.erb" do

  it "should have h1 with content 'Discuss It!'" do
    visit '/'
    page.should have_selector('h1', text: 'Discuss It!')
  end

  it "should have p with proper text" do
    visit '/'
    page.should have_selector("p", text: "Online article discussion tracker website for locating online discussions about a given article.")
  end
end