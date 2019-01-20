defmodule PairStairsWeb.StairsControllerTest do
  use PairStairsWeb.ConnCase

  test "new/2 returns registration page", %{conn: conn} do
    response =
      conn
      |> get(Routes.stairs_path(conn, :new))
      |> html_response(200)

    assert response =~ "Name"
    assert response =~ "Limit"
    assert response =~ "Submit"
  end
end
