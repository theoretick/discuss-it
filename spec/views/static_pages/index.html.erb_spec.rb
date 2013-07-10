require 'spec_helper'

describe "Index pages" do

  it "should have h1 with content 'Discuss It!'" do
    visit '/'
    page.should have_selector('h1', text: 'Discuss It!')
  end

  it "should have p with proper text" do
    visit '/'
    page.should have_selector("p", text: "Discuss-it – Online article discussion tracker website for locating online discussions about a given article.")
  end

  it "should have css bootstrap loaded" do
    # [TODO] this doesn't actually test anything... fix or delete
    visit '/'
    page.should have_selector("div.controls")
  end

  it '' do

  end

end
