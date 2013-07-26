require 'httparty'
require 'nokogiri'

namespace :slashdot do

  desc "clear db of postings"
  task :clear_db => :environment do
    puts "Deleting #{SlashdotPosting.all.length} slashdot_postings..."
    SlashdotPosting.delete_all
    puts "DONE."
  end

  desc "get recent postings"
  task :get_slashdot_postings => :environment do
    puts "Starting slashdot fetch..."
    dollah_dollah_bills_yall
    puts "DONE. Populated the DB..."
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
  # only scrape the last 7 days
  response = HTTParty::get('http://slashdot.org/archive.pl')
  doc = Nokogiri::HTML(response.body)
  parent_body_anchors = []

  # array of all urls in some recent portion of 2013
  # FIXME: this is probably where we should get comment counts... ish.
  #
  # POETRY AND M0N3Y$.
  doc.css('div.grid_24 a')[20...-1].each { |blah| parent_body_anchors << blah.attribute("href").to_s }

  # go through each posting per day(?) on archive page, traverse XML,
  # and create SlashdotPosting instance
  parent_body_anchors.each do |anchor|
    valid_anchor = 'http:' + anchor
    posting_urls = []

    posting = HTTParty::get(valid_anchor)
    document = Nokogiri::HTML(posting)

    # builds posting_url array with relevant body anchors that aren't slashdot
    # FIXME: should we include slashdot links?
    document.css('div.body a:not([href*="slashdot"])').each do |blah|
      body_url = blah.attribute("href").to_s
      # puts "archiving '#{body_url}'..."
      posting_urls << body_url
    end

    title = document.css('title').children.text

    # MAKE THE GODDAMN LISTING
    # stringified_urls = ''
    # posting_urls.each { |url| stringified_urls << url + ',' }

    s = SlashdotPosting.new
    s.site = "slashdot"
    s.permalink = valid_anchor
    # FIXME: get all and not just the first
    s.urls      = posting_urls.first
    s.title     = title
    #s.author  = balrog
    #s.comment_count = xxx
    #s.posted_date = xxx
    puts "Saving SlashdotPosting for '#{s.title}'..."
    s.save
  end # end of parent_body_anchors block
end


