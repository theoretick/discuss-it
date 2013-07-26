require 'httparty'
require 'nokogiri'

namespace :slashdot do

  desc "get recent postings"
  task :get_slashdot_postings => :environment do
    puts "Starting slashdot fetch..."
    dollah_dollah_bills_yall
    puts "Done! Populated the DB. dolah"
  end

end

#----------------------------------------------------------------------
#
# does api call to slashdot
# gets XML back
# parses relevant xml
# builds SlashdotPosting object
#
# runs daily-ish
#----------------------------------------------------------------------
# json_from_localhost_slashdot_api = {
#      "post_urls" => 2, ???????????
#   "results" => {
#          "title" => "13-Inch Haswell-Powered MacBook Air With PCIe SSD Tested"
#       "postdate" => 2013-09-29
#      "permalink" => "http://apple.slashdot.org/story/13/07/24/2055208/13-inch-haswell-powered-macbook-air-with-pcie-ssd-tested"
#   "commentcount" => 182,
#            "url" => {
#                       "http://hothardware.com/Reviews/Apples-HaswellPowered-13Inch-MacBook-Air/",
#                       "http://hothardware.com/Reviews/Apples-HaswellPowered-13Inch-MacBook-Air/?page=4"
#                    }
#        }
# }
#
#----------------------------------------------------------------------


#----------------------------------------------------------------------
# gets and creates slashdot postings
# populates db with created postings
#----------------------------------------------------------------------
def dollah_dollah_bills_yall
  response = HTTParty::get('http://slashdot.org/archive.pl?op=bytime&keyword=&year=2013')
  doc = Nokogiri::HTML(response.body)
  parent_body_anchors = []

  # array of all urls in some recent portion of 2013
  # FIXME: this is probably where we should get comment counts... ish.
  #
  # POETRY AND M0N3Y$.
  doc.css('div.grid_24 a').each { |blah| parent_body_anchors << blah.attribute("href").to_s }[20...-1]

  # go through each listing per day(?) on archive page, traverse XML,
  # and create SlashdotListing instance
  parent_body_anchors.each do |anchor|
    valid_anchor = 'http:' + anchor
    posting_urls = []

    posting = HTTParty::get(valid_anchor)
    document = Nokogiri::HTML(posting)

    # builds posting_url array with relevant body anchors that aren't slashdot
    # FIXME: should we include slashdot links?
    document.css('div.body a:not([href*="slashdot"])').each {|blah| posting_urls << blah.attribute("href").to_s}
    title = document.css('title').children.text

    # MAKE THE GODDAMN LISTING
    s = SlashdotPosting.new
    s.permalink = valid_anchor
    s.urls      = posting_urls
    s.title     = title
    #s.author  = balrog
    #s.comment_count = xxx
    #s.posted_date = xxx
    s.save
  end # end of parent_body_anchors block
end


