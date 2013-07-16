require 'spec_helper'

describe "static_pages/submit.html.erb" do

  it "should have an anchor tag 'a'" do
    visit '/static_pages/submit'
    page.has_content?('TOP RESULTS')
  end

  it "Should have an anchor tag 'a' after a valid search" do
    visit '/'
    fill_in 'query', :with => 'www.restorethefourth.net/'
    click_button 'Search'
    expect(page).to have_selector("a")
  end

  it "should load from search button" do
    visit '/'
    click_button 'Search'
    current_path.should == static_pages_submit_path
  end

  it "should link to about page" do
    visit '/'
    click_link 'About'
    current_path.should == static_pages_about_path
  end

  it "Should offer a try again link with invalid search" do
    visit '/'
    click_button 'Search'
    click_link 'Try again?'
    current_path.should == root_path
  end

  it "Should have a link back to home page" do
    visit '/static_pages/submit'
    page.has_link?('Discuss it')
  end

end

