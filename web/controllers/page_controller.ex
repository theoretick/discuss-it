defmodule DiscussIt.PageController do
  use DiscussIt.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", app_version: app_version
  end

  def search(conn, _params) do
    render conn, "search.html", app_version: app_version
  end

  def submit(conn, %{ "url" => query_url }) do
    all_results = DiscussItApi.call(query_url)
    {top_results, filtered_results} = DiscussIt.Utils.filter_results(all_results)
    render conn, "submit.html",
      query_url: query_url,
      top_results: top_results,
      all_results: all_results,
      filtered_results: filtered_results,
      app_version: app_version
  end
  def submit(conn, _params), do: render(conn, "submit.html", query_url: "", app_version: app_version)

  def about(conn, _params) do
    render conn, "about.html", app_version: app_version
  end

  defp app_version do
    {:ok, vsn} = :application.get_key(:discuss_it, :vsn)
    vsn
  end
end
