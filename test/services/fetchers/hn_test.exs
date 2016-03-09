defmodule Fetchers.HnTest do
  use DiscussIt.ServiceCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  test "fetches listings" do
    use_cassette "fetcher_hn_swift_api" do
      listings = Fetchers.Hn.call("https://swift.org/blog/swift-api-transformation/")
      assert Enum.count(listings) == 1

      listing = List.first(listings)
      assert listing["location"] == "http://news.ycombinator.com/item?id=11001818"
      assert listing["site"]     == "HackerNews"
      assert listing["url"]      == "https://swift.org/blog/swift-api-transformation/"
      assert listing["title"]    == "It's Coming: The Great Swift API Transformation"
      assert listing["score"] == 163
    end
  end
end
