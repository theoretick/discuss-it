defmodule Fetchers.Slashdot do
  # TODO
  # use HTTPoison.base

  def call(url, is_retry \\ false) do
    case HTTPoison.get(api_url() <> url,  timeout: 16000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.Parser.parse!(body)
        # |> Enum.map(&/build_listing/1)
        |> Enum.map(fn(listing) ->
          score = listing_score(listing)
          Map.merge(listing,
            %{"site" => "Slashdot",
              "location" => listing["permalink"],
              "url" => url,
              "score" => score})
        end)
      # retry at least once if timeout
      {:error, %HTTPoison.Error{reason: :timeout}} when is_retry -> []
      {:error, %HTTPoison.Error{reason: :timeout}} -> call(url, true)
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        []
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
