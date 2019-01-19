defmodule PairStairsWeb.StairsController do
  use PairStairsWeb, :controller

  alias Parear.Stairs

  def new(conn, _params) do
    put_in(conn.params["new_stairs"], %{"limit" => "5"})
    |> render("new.html")
  end

  def create(conn, %{"new_stairs" => %{"name" => name, "limit" => limit}}) do
    with stairs <- Parear.new_stairs(name, limit: limit),
         {:ok, %Stairs{id: stairs_id}} <- Parear.list(stairs) do
      conn
      |> redirect(to: Routes.stairs_path(conn, :show, stairs_id))
    end
  end

  def show(conn, %{"id" => id}) do
    {:ok, stairs} =
      Parear.reload_by_id(id)
      |> Parear.list()

    render(conn, "index.html", stairs: stairs)
  end
end
