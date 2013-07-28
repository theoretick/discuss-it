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
# GET req slashdot archive page
# GET permalinks to recent slashdot stories
# finds or creates SlashdotPosting objects from permalinks
# finds or creates Url objects from each permalink-body's anchors
#----------------------------------------------------------------------

  # enable verbose output for debugging, etc
  VERBOSE = true

  def initialize
  end

  # if VERBOSE = true, displays output and colorizes it.
  def display(message, color=:undef)
    if VERBOSE == true
      # colorize the output, baby
      colorize = {
        :black  => lambda { |text| "\033[30m#{text}\033[0m" },
        :red    => lambda { |text| "\033[31m#{text}\033[0m" },
        :green  => lambda { |text| "\033[32m#{text}\033[0m" },
        :yellow => lambda { |text| "\033[33m#{text}\033[0m" },
        :white  => lambda { |text| "\033[37m#{text}\033[0m" },
        :blue   => lambda { |text| "\033[34m#{text}\033[0m" },
        :undef  => lambda { |text| "#{text}"                }
      }

      puts colorize[color].call(message)
    end
  end

  def get_postings(timeframe='w')

    # first 21 anchors are nav links
    first_anchor = 21
    archive_url = 'http://slashdot.org/archive.pl?op=bytime&keyword=&week'

    # quicktest for integerness from string (i.e. '5')
    if timeframe.to_i.to_s == timeframe
      request_count = timeframe.to_i + first_anchor - 1 # -1 == index 0
    end

    # default: all archive_urls on page (skip last where href='page 2')
    request_count ||= -2

    response = HTTParty::get(archive_url)
    display "Response fetched...", :green
    doc = Nokogiri::HTML(response.body)
    display "Response parsed...", :green
    parent_body_anchors = []

    # array of slashdot posting urls from archive page
    archived_postings = doc.css('div.grid_24 a')[first_anchor..request_count]

    # counter for rake-task display of progress percentage
    archived_count = archived_postings.length
    display "Fetching #{archived_count} results..."

    archived_postings.each { |anchor| parent_body_anchors << anchor.attribute("href").to_s }

    # go through each posting on archive page, traverse HTML,
    # and create SlashdotPosting instance
    parent_body_anchors.each_with_index do |anchor, index|
      permalink = 'http:' + anchor
      posting_urls = []

      # find/init SlashdotPosting.new instance from each posting_url
      s = SlashdotPosting.find_or_initialize_by_permalink(permalink)
      if s.new_record?

        # open each slashdot discussion link as 'posting'
        posting = HTTParty::get(permalink)
        document = Nokogiri::HTML(posting)
        display "\nscanning #{anchor}", :yellow

        # FIXME: should we include slashdot links?
        # if not, have a more accurate RegEx exclusion (only domain, not just keyword)
        #
        # builds posting_url array with relevant body anchors that aren't slashdot
        document.css('div.body a').each do |body_anchor|
        # FIXME: if slashdot discussions work alright, delete this
        # document.css('div.body a:not([href*="slashdot"])').each do |body_anchor|
          body_url = body_anchor.attribute("href").to_s
          posting_urls << body_url
        end

        # dont bother creating a listing if no links; i.e. "Ask Slashdot" posts
        unless posting_urls.empty?

          title           = document.css('title').text
          author          = document.css('header div.details a').text
          comment_count   = document.css('span.totalcommentcnt').first.text
          # FIXME: parse date into something useable, currently "on Sunday July 21, 2013 @01:51PM"
          post_date       = document.css('header div.details time').text

          s.site          = "slashdot"
          s.permalink     = permalink
          s.title         = title
          s.author        = author
          s.comment_count = comment_count
          s.post_date = post_date

          # verbose output and progress percentage
          print "(#{(index.to_f/archived_count*100).round(1)}% done)  "
          display "Saving SlashdotPosting for '#{s.title}'...", :green
          s.save

          # find/init Url.new instance from each url in posting's body
          # and associate with SlashdotPosting instance
          posting_urls.each do |url|
            u = Url.find_or_initialize_by_target_url(url)
            u.slashdot_postings << SlashdotPosting.find_or_initialize_by_permalink(s.permalink)
            display ">  Saving associated URL: '#{url}'.", :green
            u.save
          end
        end
      end
    end # end of parent_body_anchors block
  end

end