require 'spec_helper'

describe "StaticPages" do

  describe "GET static_pages" do

    it "lands on the homepage successfully" do
      get '/'
      expect(response.status).to be(200)
    end

    it "lands on the about page successfully" do
      get 'static_pages/about'
      expect(response.status).to be(200)
    end

    it "disallows access to submit without query param" do
      expect{
        get 'static_pages/submit'
      }.to raise_error()
    end

   end
end
