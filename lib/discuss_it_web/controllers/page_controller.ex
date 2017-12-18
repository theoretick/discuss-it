defmodule DiscussItWeb.PageController do
  use DiscussItWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", app_version: app_version()
  end

  def about(conn, _params) do
    render conn, "about.html", app_version: app_version()
  end

  defp app_version do
    {:ok, vsn} = :application.get_key(:discuss_it, :vsn)
    vsn
  end
end
