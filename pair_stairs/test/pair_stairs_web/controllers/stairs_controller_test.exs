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

    test "displays participants", %{conn: conn, stairs_id: id} do
      participants =
        ["Vitor", "Kenya"]
        |> add_participants(id)

      response =
        conn
        |> get(Routes.stairs_path(conn, :show, id))
        |> html_response(200)

      for participant <- participants do
        assert response =~ participant
      end
    end

    test "displays matching count", %{conn: conn, stairs_id: id} do
      ["Vitor", "Kenya"]
      |> add_participants(id)

      for _i <- 1..37 do
        Parear.pair(id, "Vitor", "Kenya")
      end

      response =
        conn
        |> get(Routes.stairs_path(conn, :show, id))
        |> html_response(200)

      assert response =~ "37"
    end
  end

  defp add_participants(participants, stairs_id) do
    for participant <- participants do
      {:ok, _} = Parear.add_participant(stairs_id, participant)
    end

    participants
  end
end
