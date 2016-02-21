defmodule DiscussItApi do

  def call(url) do
    Fetchers.Hn.call(url) ++
    Fetchers.Slashdot.call(url) ++
    Fetchers.Reddit.call(url)
  end
end
