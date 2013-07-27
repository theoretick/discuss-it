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
  task :get_postings => :environment do
    # SlashdotPosting.delete_all
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

  # FIXME: this is probably where we should get comment counts... ish.
  # array of slashdot posting urls from archive of last 7 days
  doc.css('div.grid_24 a')[4...-1].each { |blah| parent_body_anchors << blah.attribute("href").to_s }

  # go through each posting on archive page, traverse HTML,
  # and create SlashdotPosting instance
  parent_body_anchors.each do |anchor|
    valid_anchor = 'http:' + anchor
    posting_urls = []

    # open each slashdot discussion as 'posting'
    posting = HTTParty::get(valid_anchor)
    document = Nokogiri::HTML(posting)

    # FIXME: should we include slashdot links?
    # FIXME: if not, have a more accurate slashdot exclusion (only domain, not just keyword)
    # builds posting_url array with relevant body anchors that aren't slashdot
    document.css('div.body a:not([href*="slashdot"])').each do |body_anchor|
      body_url = body_anchor.attribute("href").to_s
      posting_urls << body_url
    end

    # dont bother creating a listing if no links; i.e. "Ask Slashdot" posts
    unless posting_urls.empty?

      # find slashdot article title
      title = document.css('title').children.text

      # find posting author
      author = document.css('header div.details a').text

      # FIXME: parse this into something useable
      # find posting post_date
      # => "on Sunday July 21, 2013 @01:51PM"
      post_date = document.css('header div.details time').text

      # find comment_count
      comment_count = document.css('span.totalcommentcnt').first.text


      s = SlashdotPosting.new
      s.site = "slashdot"
      s.permalink = valid_anchor
      # FIXME: get all and not just the first url
      s.urls      = posting_urls.first
      s.title     = title
      s.author  = author
      s.comment_count = comment_count
      # s.post_date = post_date
      puts "Saving SlashdotPosting for '#{s.title}'..."
      s.save
    end
  end # end of parent_body_anchors block
end

