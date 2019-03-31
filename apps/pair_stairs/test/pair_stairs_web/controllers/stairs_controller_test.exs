defmodule PairStairsWeb.StairsControllerTest do
  use PairStairsWeb.ConnCase

  @tag :integration
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
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repository.Parear.Repo)
      Ecto.Adapters.SQL.Sandbox.mode(Repository.Parear.Repo, {:shared, self()})
      stairs_id = Parear.new_stairs("Whiskey", limit: 100)
      %{stairs_id: stairs_id}
    end

    @tag :integration
    test "displays stairs name", %{conn: conn, stairs_id: id} do
      response =
        conn
        |> get(Routes.stairs_path(conn, :show, id))
        |> html_response(200)

      assert response =~ "Whiskey"
    end

    @tag :integration
    test "sets stairs id", %{conn: conn, stairs_id: id} do
      response =
        conn
        |> get(Routes.stairs_path(conn, :show, id))
        |> html_response(200)

      assert response =~ "data-stairs-id=\"#{id}\""
    end
  end
end
