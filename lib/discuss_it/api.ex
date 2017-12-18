defmodule DiscussIt.Api do

  def call(input_url, strip_params \\ false) do
    url = if strip_params, do: DiscussIt.Utils.strip_params(input_url), else: input_url

    Fetchers.Hn.call(url) ++
    # Fetchers.Slashdot.call(url) ++
    Fetchers.Reddit.call(url)
  end
end
