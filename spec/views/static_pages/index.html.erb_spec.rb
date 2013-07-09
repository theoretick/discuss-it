require 'spec_helper'

describe "static_pages/index.html.erb" do
  pending "add some examples to (or delete) #{__FILE__}"
end

describe "Index pages" do
  it "should have h1 with content 'Discuss It!'" do
    visit '/index'
    page.should have_selector('h1', :text => 'Discuss It!')
  end
end
