defmodule DiscussItWeb.ApiControllerTest do
  use DiscussItWeb.ConnCase
  import Mock

  test "GET /", %{conn: conn} do
    {:ok, app_version} = :application.get_key(:discuss_it, :vsn)

    conn = get conn, "/api"

    assert json_response(conn, 200) == %{
      "version" => app_version
    }
  end

  test "GET /submit", %{conn: conn} do

    with_mock DiscussIt.Api, [call: fn(_query_url) -> [] end] do
      conn = get conn, "/api/submit?url=http%3A%2F%2Fexample.com"

      assert called DiscussIt.Api.call("http://example.com")
    end
  end
end
