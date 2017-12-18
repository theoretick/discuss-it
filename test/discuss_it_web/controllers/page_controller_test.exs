defmodule DiscussItWeb.PageControllerTest do
  use DiscussItWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Discuss It!"
  end

  test "GET /about", %{conn: conn} do
    conn = get conn, "/about"
    assert html_response(conn, 200) =~ "about-thumbnails-container"
  end
end
