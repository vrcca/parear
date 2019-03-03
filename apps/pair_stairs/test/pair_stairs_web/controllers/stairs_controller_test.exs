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

  describe "show/2" do
    setup do
      %{stairs_id: Parear.new_stairs("Whiskey", limit: 100)}
    end

    test "displays stairs name", %{conn: conn, stairs_id: id} do
      response =
        conn
        |> get(Routes.stairs_path(conn, :show, id))
        |> html_response(200)

      assert response =~ "Whiskey"
    end

    test "sets stairs id", %{conn: conn, stairs_id: id} do
      response =
        conn
        |> get(Routes.stairs_path(conn, :show, id))
        |> html_response(200)

      assert response =~ "data-stairs-id=\"#{id}\""
    end
  end
end
