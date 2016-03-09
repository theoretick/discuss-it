defmodule Fetchers.RedditTest do
  use DiscussIt.ServiceCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  test "fetches listings" do
    use_cassette "fetcher_reddit_swift_api", match_requests_on: [:query] do
      listings = Fetchers.Reddit.call("https://swift.org/blog/swift-api-transformation/")
      assert Enum.count(listings) == 1

      listing = List.first(listings)

      assert listing["location"] == "http://www.reddit.com/r/hackernews/comments/43fge0/its_coming_the_great_swift_api_transformation/"
      assert listing["site"]     == "Reddit"
      assert listing["url"]      == "https://swift.org/blog/swift-api-transformation/"
      assert listing["title"]    == "It's Coming: The Great Swift API Transformation"
      assert listing["score"] == 1
      assert listing["num_comments"] == 1
    end
  end
end
