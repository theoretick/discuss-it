defmodule DiscussIt.ApiController do
  use DiscussIt.Web, :controller

  def index(conn, _params) do
    json conn, %{ "version" => app_version }
  end

  def submit(conn, %{ "url" => query_url }) do
    all_results = DiscussItApi.call(query_url)
    {top_results, filtered_results} = DiscussIt.Utils.filter_results(all_results)
    json conn, %{
      "query_url" => query_url,
      "top_results" => top_results,
      "all_results" => all_results,
      "filtered_results" => filtered_results
    }
  end

  defp app_version do
    {:ok, vsn} = :application.get_key(:discuss_it, :vsn)
    vsn
  end
end
