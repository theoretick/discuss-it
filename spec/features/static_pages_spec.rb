require 'spec_helper'

describe "StaticPages" do

  describe "GET static_pages", :vcr do

    it "lands on the homepage successfully" do
      visit '/'
      expect(page.status_code).to be(200)
    end

    it "lands on the about page successfully" do
      visit '/static_pages/about'
      expect(page.status_code).to be(200)
    end

    it "disallows access to submit without query param" do
      expect{
        visit '/static_pages/submit'
      }.to raise_error()
      # FIXME: specify the error
    end

  end

end
