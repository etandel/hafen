defmodule HafenWeb.PageControllerTest do
  use HafenWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Hafen"
  end
end
