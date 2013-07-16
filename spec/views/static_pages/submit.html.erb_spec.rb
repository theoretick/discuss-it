require 'spec_helper'

describe "static_pages/submit.html.erb", :vcr do

  before(:each) do
    # non-external capybara calls use tag :locals
    if (:locals == true)
      VCR.turn_off!
    end
  end

  # it "should not be reachable without param", :locals => true do
  #   visit '/static_pages/submit'
  # end

  it "Should have an anchor tag 'a' after a valid search" do
    visit '/'
    fill_in 'query', :with => 'www.restorethefourth.net/'
    click_button 'Search'
    expect(page).to have_selector("a")
  end

  it "should display alert div with empty doublequoted str", :locals => true do
    visit '/'
    fill_in 'query', :with => '""'
    click_button 'Search'
    expect(page).to have_selector('div.alert')
  end

  it "should display alert div with empty singlequote str", :locals => true

  it "should link to about page", :locals => true do
    visit '/'
    click_link 'About'
    current_path.should == static_pages_about_path
  end

  # it "Should offer a try again link with invalid search" do
  #   visit '/'
  #   click_button 'Search'
  #   click_link 'Try again?'
  #   current_path.should == root_path
  # end

  # it "Should have a link back to home page" do
  #   visit '/static_pages/submit'
  #   page.has_link?('Discuss it')
  # end

end

