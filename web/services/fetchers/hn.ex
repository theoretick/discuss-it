defmodule Fetchers.Hn do
  # TODO
  # use HTTPoison.base

  def call(url) do
    case HTTPoison.get(api_url <> url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        listings = Poison.Parser.parse!(body)
        Enum.map(listings["hits"], fn(listing) ->
          location = location_url(listing["objectID"])
          Map.merge(listing,
            %{"site" => "HackerNews", "location" => location, "score" => listing_score(listing)})
        end)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        raise "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        []
    end
  end

  def location_url(object_id) do
    "http://news.ycombinator.com/item?id=#{object_id}"
  end

  def listing_score(listing) do
    # TODO: more betterer
    listing["points"]
  end

  def api_url do
    "http://hn.algolia.com/api/v1/search?restrictSearchableAttributes=url&query="
  end
end
