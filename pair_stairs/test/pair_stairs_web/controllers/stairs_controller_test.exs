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
    test "displays stairs name", %{conn: conn} do
      id = Parear.new_stairs("Whiskey")

      response =
        conn
        |> get(Routes.stairs_path(conn, :show, id))
        |> html_response(200)

      assert response =~ "Whiskey"
    end

    test "displays participants", %{conn: conn} do
      id = Parear.new_stairs("Whiskey")
      participants = ["Vitor", "Kenya"]

      for participant <- participants do
        {:ok, _} = Parear.add_participant(id, participant)
      end

      response =
        conn
        |> get(Routes.stairs_path(conn, :show, id))
        |> html_response(200)

      for participant <- participants do
        assert response =~ participant
      end
    end

    test "displays matching count" do
    end
  end
end
