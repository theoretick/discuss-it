#----------------------------------------------------------------------
# SlashdotApi v1.0
#
# - scrapes Slashdot to build DB objects SlashdotPostings and Urls
# each has_many of the other. Validates presence of permalink/target_url
# and uniqueness.
#
# part of DiscussIt project
#
# http://github.com/theoretick/discussit
#----------------------------------------------------------------------
require 'nokogiri'
require 'httparty'


class SlashdotApi
#----------------------------------------------------------------------
# does api call to slashdot
# parses returned html
# builds SlashdotPosting object
# builds Url object
#----------------------------------------------------------------------

  def initialize
  end

  def get_postings(timeframe='w')
    # FIXME: consider parsing for specific day:
    # > 2013-07-26 => http://slashdot.org/?issue=20130726
    if timeframe.is_a? Integer
      request_count = timeframe
    end

    archive_url ||= 'http://slashdot.org/archive.pl?op=bytime&keyword=&week'
    request_count ||= -1 # grabs all archive_urls on page

    response = HTTParty::get(archive_url)
    doc = Nokogiri::HTML(response.body)
    parent_body_anchors = []

    # array of slashdot posting urls from archive page
    # first 4 are nav links
    archived_postings = doc.css('div.grid_24 a')[4..request_count]

    # counter for rake-task display of progress percentage
    archived_count = archived_postings.length.to_f

    archived_postings.each { |anchor| parent_body_anchors << anchor.attribute("href").to_s }

    # go through each posting on archive page, traverse HTML,
    # and create SlashdotPosting instance
    parent_body_anchors.each_with_index do |anchor, index|
      permalink = 'http:' + anchor
      posting_urls = []

      # open each slashdot discussion link as 'posting'
      posting = HTTParty::get(permalink)
      document = Nokogiri::HTML(posting)

      # FIXME: should we include slashdot links?
      # if not, have a more accurate RegEx exclusion (only domain, not just keyword)
      #
      # builds posting_url array with relevant body anchors that aren't slashdot
      document.css('div.body a:not([href*="slashdot"])').each do |body_anchor|
        body_url = body_anchor.attribute("href").to_s
        posting_urls << body_url
      end

      # dont bother creating a listing if no links; i.e. "Ask Slashdot" posts
      unless posting_urls.empty?

        # parses all relevant data off slashdot page
        title = document.css('title').children.text
        author = document.css('header div.details a').text
        # FIXME: parse this into something useable
        # currently => "on Sunday July 21, 2013 @01:51PM"
        post_date     = document.css('header div.details time').text
        comment_count = document.css('span.totalcommentcnt').first.text

        s = SlashdotPosting.find_or_create_by_permalink(permalink)
        s.site          = "slashdot"
        s.permalink     = permalink
        s.title         = title
        s.author        = author
        s.comment_count = comment_count
        s.post_date = post_date

        # FIXME: did I forget how to do order of operations?
        print "\n (#{((index/archived_count)*100).round(2)}% done)  "
        puts "Saving SlashdotPosting for '#{s.title}'..."
        s.save

        # create Url.new instance from each posting_url
        # and associate with SlashdotPosting instance
        posting_urls.each do |url|
          u = Url.find_or_create_by_target_url(url)
          u.slashdot_postings << SlashdotPosting.find_or_create_by_permalink(s.permalink)
          puts ">  Associating URL: '#{url}'."
          u.save
        end

      end
    end # end of parent_body_anchors block
  end

end