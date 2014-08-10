require 'minitest/autorun'
require '../../lib/discuss_it/filter'

class MockResult

  attr_reader :comment_count

  def initialize(c_count)
    @comment_count = c_count
  end

  alias_method :num_comments, :comment_count
end

class TestFilter < MiniTest::Spec

  def test_filter_threads_removes_no_comments_results
    good_results, bad_results = DiscussIt::Filter.filter_threads(mock_results)
    good_results.length.must_equal 1
    bad_results.length.must_equal 1
  end

  private

  def mock_results
    [
    MockResult.new(1),
    MockResult.new(0),
    ]
  end
end
