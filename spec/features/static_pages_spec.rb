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

    it "disallows access to submit without url param" do
      expect{
        visit '/submit'
      }.to raise_error()
    end

  end

  describe "Submit a link through index form" do

    before(:each) do

      VCR.use_cassette("submit_page_yorickp_results") do
        visit '/'

        within(".field") do
          fill_in 'search[query_url]', :with => 'yorickpeterse.com/articles/debugging-with-pry/'
        end

        click_button 'Discuss This!'
      end

    end

  end

  # it "should have 'try again' anchor if no results found"

end

