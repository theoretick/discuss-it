defmodule Fetchers.SlashdotTest do
  use DiscussIt.ServiceCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  test "fetches listings" do
    use_cassette "fetcher_slashdot_swift_api" do
      listings = Fetchers.Slashdot.call("http://www.theguardian.com/world/2013/sep/05/nsa-gchq-encryption-codes-security")
      assert Enum.count(listings) == 2

      # ensure consistent first result
      listing = Enum.find(listings, fn(listing) -> listing["id"] == 984 end)

      assert listing["location"] == "http://yro.slashdot.org/story/13/09/05/1951204/nsa-foils-much-internet-encryption"
      assert listing["site"]     == "Slashdot"
      assert listing["url"]      == "http://www.theguardian.com/world/2013/sep/05/nsa-gchq-encryption-codes-security"
      assert listing["title"]    == "NSA Foils Much Internet Encryption - Slashdot"
      assert listing["score"] == 387
      assert listing["comment_count"] == 387
    end
  end
end
