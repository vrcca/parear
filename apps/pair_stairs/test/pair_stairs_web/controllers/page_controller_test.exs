defmodule PairStairsWeb.PageControllerTest do
  use PairStairsWeb.ConnCase

  @tag :integration
  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Pair Matrix"
  end
end
