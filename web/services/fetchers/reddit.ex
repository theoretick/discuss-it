defmodule Fetchers.Reddit do
  # TODO
  # use HTTPoison.base

  @doc """
    Due to some API design insanity, reddit stores URLs separately with and without
    a trailing slash. So we do 2 calls here and combine the results.

    ## HACK: this is super nasty, fix it.
  """
  def call(url) do
    if String.ends_with?(url, "/")  do
      [
        String.strip(url, ?/) |> fetch,
        fetch(url)
      ]
      |> Enum.concat
    else
      [
        fetch(url <> "/"),
        fetch(url)
      ]
      |> Enum.concat
    end
  end

  def fetch(url) do
    case HTTPoison.get(api_url <> url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        listings = Poison.Parser.parse!(body)
        Enum.map(listings["data"]["children"], fn(%{"data" => listing}) ->
          location = location_url(listing["permalink"])
          score    = listing_score(listing)
          Map.merge(listing,
            %{"site" => "Reddit", "location" => location, "score" => score})
        end)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        raise "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        []
    end
  end

  def location_url(permalink) do
     "http://www.reddit.com#{permalink}"
  end

  def listing_score(listing) do
    # TODO: more betterer
    listing["score"]
  end

  def api_url do
    "http://www.reddit.com/api/info.json?url="
  end
end
