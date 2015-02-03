
require 'minitest/autorun'
require 'hashie'
require '../../lib/discuss_it/listings'

class TestListing < MiniTest::Spec

  class MockListing < DiscussIt::Listing::BaseListing
    # Oh noez, i dont overwrite `ranking` and `score`!
  end

  def test_all_listings_respond_to_score
    all_listings.each do |listing|
      listing.must_respond_to :score
    end
  end

  def test_all_listings_respond_to_ranking
    all_listings.each do |listing|
      listing.must_respond_to :ranking
    end
  end

  def test_raise_error_if_listing_interface_does_not_define_score
    proc{ MockListing.new.score }.must_raise StandardError
  end

  def test_raise_error_if_listing_interface_does_not_define_ranking
    proc{ MockListing.new.ranking }.must_raise StandardError
  end

  def test_reddit_listing_has_subreddit_accessor
    reddit_listing.must_respond_to :subreddit
  end

  def test_all_listings_have_title_accessor
    all_listings.each do |listing|
      listing.must_respond_to :title
    end
  end

  private

  def all_listings
    [
      reddit_listing,
      hn_listing,
      slashdot_listing
    ]
  end

  def reddit_listing
    DiscussIt::Listing::RedditListing.new({
      "subreddit" => "technology",
      "title" => "e-David, a robotic system built by researchers at the U of Konstanz, employs a variety of styles to produce paintings remarkably similar to their human counterparts -- \"the final products seem to display that perfectly imperfect quality we generally associate with human works of art\"",
      "permalink" => "/r/technology/comments/1j8h6p/edavid_a_robotic_system_built_by_researchers_at/",
      "url" => "http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/",
      "ups" => 14,
      "downs" => 11,
      "score" => 3,
      "num_comments" => 0
    })
  end

  def hn_listing
    DiscussIt::Listing::HnListing.new({
      "title" => "Robots paint with flaws too, like humans",
      "url" => "http://singularityhub.com/2013/07/27/canvas-camera-brush-and-algorithms-enable-robot-artists-beautiful-paintings/",
      "points" => 2,
      "num_comments" => 0
    })
  end

  def slashdot_listing
    DiscussIt::Listing::SlashdotListing.new({
      "title" => "Robot Produces Paintings With That Imperfect Human Look - Slashdot",
      "permalink" => "http://hardware.slashdot.org/story/13/07/28/2056210/robot-produces-paintings-with-that-imperfect-human-look",
      "comment_count" => 74
    })
  end
end
