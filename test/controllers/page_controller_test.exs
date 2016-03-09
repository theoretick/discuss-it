defmodule DiscussIt.PageControllerTest do
  use DiscussIt.ConnCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Online discussion tracker for finding conversations"
  end

  test "GET /about", %{conn: conn} do
    conn = get conn, "/about"
    assert html_response(conn, 200) =~ "How often do you find an article online and want to track down a discussion about it?"
  end

  test "GET /submit?url=http://www.apple.com/customer-letter", %{conn: conn} do
    use_cassette "page_controller_test" do
      conn = get conn, "/submit?url=http://www.apple.com/customer-letter"

      resp = html_response(conn, 200)
      assert resp =~ "Online discussion tracker for finding conversations"
      # Reddit article
      assert resp =~ "Letter from Apple to all customers"
      # Slashdot article
      assert resp =~ "Google CEO Finally Chimes In On FBI Encryption Case, Says He Agrees With Apple - Slashdot"
      # HackerNews article
      assert resp =~ "Answers to your questions about Apple and security"
    end
  end
end
