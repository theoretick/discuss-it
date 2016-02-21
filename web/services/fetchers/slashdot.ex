defmodule Fetchers.Slashdot do
  # TODO
  # use HTTPoison.base

  def call(url) do
    case HTTPoison.get(api_url <> url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.Parser.parse!(body)
        |> Enum.map(fn(listing) ->
          score = listing_score(listing)
          Map.merge(listing,
            %{"site" => "Slashdot",
              "location" => listing["permalink"],
              "url" => url,
              "score" => score})
        end)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def listing_score(listing) do
    # TODO: more betterer
    listing["comment_count"]
  end

  def api_url do
    "https://slashdot-api.herokuapp.com/slashdot_postings/search?url="
  end
end
