defmodule DiscussIt.Utils do

  @doc """
    Filters top results per source and discussion-less results

    ## Examples
        iex> DiscussIt.Utils.filter_results([])
        {[], []}
  """
  def filter_results(_result_set) do
    {[], []}
  end

  @doc """
    Strips params from an input url

    ## Examples
        iex> DiscussIt.Utils.strip_params("http://example.com/foo?foo=bar&bar=baz")
        "http://example.com/foo"
  """
  def strip_params(url) do
    url
    |> String.split("?")
    |> List.first
  end
end
