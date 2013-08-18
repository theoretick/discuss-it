require 'spec_helper'

describe "StaticPages" do

  describe "GET static_pages" do

    it "lands on the homepage successfully" do
      visit '/'
      expect(page.status_code).to be(200)
    end

    it "lands on the about page successfully" do
      visit '/about'
      expect(page.status_code).to be(200)
    end

    it "disallows access to submit without query param" do
      expect{
        visit '/submit'
      }.to raise_error()
    end

    # it "should load static_pages index at root" do
    #   visit '/index'
    #   expect(current_path).to eq('/')
    # end

  end

  describe "Submit a link through index form" do

    before(:each) do

      VCR.use_cassette("submit_page_yorickp_results") do
        visit '/'

        within(".controls") do
          fill_in 'query', :with => 'yorickpeterse.com/articles/debugging-with-pry/'
        end

        click_button 'Search'
      end

    end

    it "should have anchor results in top_results" do
      within("#top-results") do
        expect(page).to have_selector('a')
      end
    end

    it "should have anchor results in top_results" do
      within("#all-results") do
        expect(page).to have_selector('a')
      end
    end

  end

  it "should have 'try again' anchor if no results found"

  #   page.should have_selector('h1', text: 'Discuss It!')

end

