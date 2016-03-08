defmodule DiscussIt.PageControllerTest do
  use DiscussIt.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Online discussion tracker for finding conversations"
  end
end
